
# SocketIO::Emitter

A Ruby implementation of [socket.io-emitter](https://github.com/Automattic/socket.io-emitter).

## How to use

```ruby
require 'socket.io-emitter'

emitter = SocketIO::Emitter.new
emitter.emit('time', DateTime.now.to_s)
```

## Installation

Add this line to your application's Gemfile:

    gem 'socket.io-emitter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install socket.io-emitter

## API

### Emitter.new([opts])

The following options are allowed:

- key: the name of the key to pub/sub events on as prefix (`socket.io`)
- redis: the Instance of [Redis](https://github.com/redis/redis-rb) (`redis://127.0.0.1:6379/0`)

### Emitter#to(room)

Specifies a specific room that you want to emit to.

### Emitter#in(room)

_Alias of `Emitter#to`._

### Emitter#of(namespace)

Specifies a specific namespace that you want to emit to.

## License

MIT
