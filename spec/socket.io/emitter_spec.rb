require 'spec_helper'
require 'timeout'

describe SocketIO::Emitter do
  include Timeout

  let(:emitter) { SocketIO::Emitter.new(redis: Redis.new(host: "localhost", port: 6380)) }

  describe "integration tests" do
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

    it 'should be able to emit messages to room' do
      emitter.of('/room').to('room').emit('room event', 'room payload')

      timeout(1) do
        expect($child_io.gets.chomp).to eq 'room payload'
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

  describe "configuration" do
    it 'builds a new object each time a new room is added' do
      single = emitter.in("first")
      double = single.in("second")

      expect(emitter.instance_variable_get(:@rooms)).to eq []
      expect(single.instance_variable_get(:@rooms)).to eq ['first']
      expect(double.instance_variable_get(:@rooms)).to eq ['first', 'second']
    end

    it 'builds a new object each time the namespace is changed' do
      first = emitter.of("first")
      second = first.of("second")

      expect(emitter.instance_variable_get(:@nsp)).to be nil
      expect(first.instance_variable_get(:@nsp)).to eq "first"
      expect(second.instance_variable_get(:@nsp)).to eq "second"
    end

    %w(json volatile broadcast).map(&:to_sym).each do |flag|
      it "builds a new object each time the #{flag} flag is changed" do
        flagged = emitter.send(flag)

        expect(emitter.instance_variable_get(:@flags)[flag]).to be nil
        expect(flagged.instance_variable_get(:@flags)[flag]).to be true
      end
    end
  end
end
