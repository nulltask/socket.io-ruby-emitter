$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

pwd = File.expand_path('..', __FILE__)
require 'socket.io/emitter'

RSpec.configure do |config|
  config.before(:suite) do
    redis_log = File.open(File.join(pwd, "redis.log"), "w")
    redis_pid = fork do
      exec("redis-server #{File.join(pwd, "redis.conf")}", :out => redis_log)
    end

    sleep 1

    $child_io = IO.popen("node #{File.join(File.dirname(__FILE__), "testapp.js")}")

    sleep 0.5

    at_exit do
      begin
        Process.kill(:SIGINT, $child_io.pid)
        Process.waitpid($child_io.pid)
        Process.kill(:SIGINT, redis_pid)
        Process.waitpid(redis_pid)
        redis_log.close
      rescue Errno::ESRCH, Errno::ECHILD
      end
    end
  end
end
