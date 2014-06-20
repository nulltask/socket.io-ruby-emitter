
require 'socket.io/emitter/version'
require 'msgpack'
require 'redis'

module SocketIO
  class Emitter
    module Type
      EVENT = 2
      BINARY_EVENT = 5
    end

    FLAGS = %w(json volatile broadcast)

    def initialize(options = {})
      @redis = options[:redis] || Redis.new
      @key = "#{options[:key] || 'socket.io'}#emitter";
      @rooms = []
      @flags = {}
    end

    FLAGS.each do |flag|
      define_method(flag) do
        @flags[flag.to_sym] = true
        self
      end
    end

    def in(room)
      @rooms << room unless @rooms.include?(room)
      self
    end
    alias :to :in

    def of(nsp)
      @flags[:nsp] = nsp
      self
    end

    def emit(*args)
      packet = {}
      packet[:type] = has_binary?(args) ? Type::BINARY_EVENT : Type::EVENT
      packet[:data] = args

      if @flags.has_key?(:nsp)
        packet[:nsp] = @flags[:nsp]
        @flags.delete(:nsp)
      else
        packet[:nsp] = '/'
      end

      packed = MessagePack.pack([packet, { rooms: @rooms, flags: @flags }])
      @redis.publish(@key, packed)

      @rooms.clear
      @flags.clear

      self
    end
  end

  private

  def has_binary?(args)
    args.select {|x| x.is_a?(String)}.any? {|str|
      str.encoding == ASCII_8BIT && !str.ascii_only?
    }
  end
end
