require "async"
require "async/http"

UPSTREAM = Async::HTTP::Endpoint.parse("http://127.0.0.1:19861")
PROXY = Async::HTTP::Endpoint.parse("http://127.0.0.1:19862")

class Chained < Protocol::HTTP::Middleware
  def initialize(delegate, client)
    super(delegate)
    @client = client
  end

  def call(request) = @client.get(request.path)

  def close
    @client.close
    super
  end
end

class DeadEnd
  def initialize(client)
    @client = client
  end

  def call(request) = @client.get(request.path)

  def close = nil
end

Async do
  upstream = Async::HTTP::Server.for(UPSTREAM) do |request|
    sleep 0.2
    Protocol::HTTP::Response[200, {}, ["socket #{request.peer.address.ip_port}"]]
  end.run

  [:chained, :deadend].each do |variant|
    client = Async::HTTP::Client.new(UPSTREAM)
    app = variant == :chained ? Chained.new(Protocol::HTTP::Middleware::NotFound, client) : DeadEnd.new(client)

    proxy = Async::HTTP::Server.for(PROXY) { |request| app.call(request) }.run
    front = Async::HTTP::Client.new(PROXY)

    5.times.map { |i| Async { front.get("/#{i}").read } }.each(&:wait)
    puts format("%-8s served      upstream pool=%s", variant, client.pool)

    front.close
    proxy.stop

    app.close
    puts format("%-8s app.close   upstream pool=%s", variant, client.pool)

    client.close
  end

  upstream.stop
end
