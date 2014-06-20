require 'spec_helper'
require 'timeout'

describe SocketIO::Emitter do
  include Timeout

  let(:emitter) { SocketIO::Emitter.new(redis: Redis.new(host: "localhost", port: 6380)) }
  it 'should be able to emit messages to client' do
    emitter.emit('broadcast event', 'broadcast payload')

    timeout(1) do
      expect($child_io.gets.chomp).to eq 'broadcast payload'
    end
  end

  it 'should be able to emit messages to namespace' do
    emitter.of('/nsp').broadcast.emit('broadcast event', 'nsp broadcast payload')

    timeout(1) do
      expect($child_io.gets.chomp).to eq 'nsp broadcast payload'
    end
  end

  it 'should not emit message to all namespace' do
    emitter.of('/nsp').broadcast.emit('nsp broadcast event', 'nsp broadcast payload')

    timeout(1) do
      expect($child_io.gets.chomp).to eq 'GOOD'
    end

    expect {
      timeout(2) do
        $child_io.gets
      end
    }.to raise_error(TimeoutError)
  end
end
