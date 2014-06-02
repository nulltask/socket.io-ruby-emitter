
require 'socket.io/emitter/version'
require 'msgpack'
require 'redis'

module SocketIO
  class Emitter
    module Type
      EVENT = 2
      BINARY_EVENT = 5
    end

    def initialize(options = {})
      @redis = options[:redis] || Redis.new
      @key = "#{options[:key] || 'socket.io'}#emitter";
      @rooms = []
      @flags = {}
    end

    def method_missing(name)
      match = /(?<flag>\S+)\?$/.match(name)
      unless match.nil?
        return !!@flags[:flag]
      end
      @flags[name.to_sym] = true
      self
    end

    def in(room)
      @rooms << room unless @rooms.includes?(room)
      self
    end

    def to(room)
      self.in(room)
    end

    def of(nsp)
      @flags[:nsp] = nsp
      self
    end

    def emit(*args)
      data = []
      packet = {}
      packet[:type] = Type::EVENT

      args.each do |arg|
        data << arg.to_s
      end

      if self.binary?
        packet[:type] = Type::BINARY_EVENT
      end

      packet[:data] = data

      unless @flags[:nsp].nil?
        packet[:nsp] = @flags[:nsp]
        @flags.delete(:nsp)
      else
        packet[:nsp] = '/'
      end

      packed = MessagePack.pack([packet, [rooms: @rooms, flags: @flags]])
      @redis.publish(@key, packed)

      @rooms = []
      @flags = {}

      self
    end
  end
end
