require "async"
require "async/http"

class DeadEnd
  def initialize(router)
    @router = router
  end

  def call(request) = respond(@router.call(request), request)

  def close = nil

  private

  def respond(handler, request)
    case handler
    when nil
      Protocol::HTTP::Response[404, {}, ["not found"]]
    when String
      Protocol::HTTP::Response[200, {}, [handler]]
    when Protocol::HTTP::Body::Readable
      Protocol::HTTP::Response[200, {}, handler]
    else
      respond(handler.call(request), request)
    end
  end
end

class Chained < Protocol::HTTP::Middleware
  def self.build(router, delegate = Protocol::HTTP::Middleware::NotFound) = new(delegate, router)

  def initialize(delegate, router)
    super(delegate)
    @router = router
  end

  def call(request)
    case handler = @router.call(request)
    when nil then super
    when Protocol::HTTP::Body::Readable then Protocol::HTTP::Response[200, {}, handler]
    else handler
    end
  end
end

ROUTER = proc do |request|
  body = Protocol::HTTP::Body::Writable.new

  Async do
    5.times do |i|
      body.write("chunk #{i}\n")
      sleep 0.05
    end
    body.close_write
  end

  body
end

puts format("Response[] keeps the body: %s", Protocol::HTTP::Response[200, {}, Protocol::HTTP::Body::Writable.new].body.class)
puts

def drain(label, app, port)
  endpoint = Async::HTTP::Endpoint.parse("http://127.0.0.1:#{port}")
  server_task = Async::HTTP::Server.new(app, endpoint).run
  client = Async::HTTP::Client.new(endpoint)
  response = client.get("/stream")

  puts format("%s  transfer-encoding=%p content-length=%p", label, response.headers["transfer-encoding"], response.body.length)

  start = Async::Clock.now
  while chunk = response.body.read
    puts format("  +%6.1fms %p", (Async::Clock.now - start) * 1000, chunk)
  end

  response.close
  client.close
  app.close
  server_task.stop
end

Async do
  drain("deadend (close = nil)", DeadEnd.new(ROUTER), 9701)
  puts
  drain("chained (Middleware)  ", Chained.build(ROUTER), 9702)
end
