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
      @nsp = nil
      @rooms = []
      @flags = {}
      # Random UID
      @uid = ('a'..'z').to_a.shuffle[0,6].join
    end

    FLAGS.each do |flag|
      define_method(flag) { clone.enable_flag(flag) }
    end

    def in(room)
      clone.add_room(room)
    end
    alias :to :in

    def of(nsp)
      clone.select_namespace(nsp)
    end

    def emit(*args)
      packet = {}
      packet[:type] = has_binary?(args) ? Type::BINARY_EVENT : Type::EVENT
      packet[:data] = args
      packet[:nsp] = @nsp || '/'

      packed = MessagePack.pack([@uid, packet, { rooms: @rooms, flags: @flags }])
      @redis.publish(@key, packed)

      self
    end

    protected

    def add_room(room)
      @rooms += [room] unless @rooms.include?(room)
      self
    end

    def select_namespace(nsp)
      @nsp = nsp
      self
    end

    def enable_flag(flag)
      @flags = @flags.merge(flag.to_sym => true)
      self
    end

    private

    def has_binary?(args)
      args.select {|x| x.is_a?(String)}.any? {|str|
        str.encoding == Encoding::ASCII_8BIT && !str.ascii_only?
      }
    end
  end
end
