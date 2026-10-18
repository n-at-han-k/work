require "async"
require "async/http"

LIVE = Hash.new(0)

module ClientCensus
  def initialize(...)
    super
    @census_closed = false
    LIVE[[@endpoint.to_s, @protocol.to_s]] += 1
  end

  def close
    super
  ensure
    unless @census_closed
      @census_closed = true
      LIVE[[@endpoint.to_s, @protocol.to_s]] -= 1
    end
  end
end

Async::HTTP::Client.prepend(ClientCensus)

ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:19881")

Async do
  server = Async::HTTP::Server.for(ENDPOINT) { Protocol::HTTP::Response[200, {}, ["ok"]] }.run

  a = Async::HTTP::Client.new(ENDPOINT)
  b = Async::HTTP::Client.new(ENDPOINT)
  a.get("/").read
  p [:two_open, LIVE.values.sum]

  a.close
  p [:one_closed, LIVE.values.sum]

  a.close
  p [:double_close, LIVE.values.sum]

  internet = Async::HTTP::Internet.new
  internet.get("http://127.0.0.1:19881/").read
  p [:internet_opened, LIVE.values.sum, internet.clients.size]

  internet.close
  p [:internet_closed, LIVE.values.sum, internet.clients.size]

  b.close
  p [:all_closed, LIVE.values.sum, LIVE]

  server.stop
end
