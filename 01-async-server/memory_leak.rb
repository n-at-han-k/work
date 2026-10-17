require "async"
require "async/http/server"
require "async/http/client"
require "async/http/endpoint"
require "memory/leak"

ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:9295")

RETAINED = []

Async do |task|
  server = Async::HTTP::Server.for(ENDPOINT) do |request|
    RETAINED << request.read.to_s
    Protocol::HTTP::Response[200, {}, ["retained #{RETAINED.size}"]]
  end

  listening = task.async { server.run }

  client = Async::HTTP::Client.new(ENDPOINT)

  monitor = Memory::Leak::Monitor.new(
    Process.pid,
    threshold_size: 10 * 1048576,
    increase_limit: 3
  )

  body = "x" * 1048576

  puts "Async::HTTP::Server.for, handler retains every request body"
  puts

  8.times do |round|
    30.times { client.post("/", {}, [body]).read }
    monitor.sample!

    puts format(
      "  round %d  retained=%3d  current=%6.1fMB  increases=%d/%d  leaking=%p",
      round,
      RETAINED.size,
      monitor.current_size / 1048576.0,
      monitor.increase_count,
      monitor.increase_limit,
      monitor.leaking?
    )

    if monitor.leaking?
      puts
      puts "  memory-leak flagged the server after #{RETAINED.size} requests"
      break
    end
  end

  client.close
  listening.stop
end
