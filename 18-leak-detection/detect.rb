require "async"
require_relative "census"

UPSTREAM = Async::HTTP::Endpoint.parse("http://127.0.0.1:19871")

SHARED = Async::HTTP::Client.new(UPSTREAM)
LEAKED = []

Async do
  upstream = Async::HTTP::Server.for(UPSTREAM) { Protocol::HTTP::Response[200, {}, ["ok"]] }.run

  baseline = Census.snapshot

  20.times { SHARED.get("/").read }
  Census.report("shared client", baseline, Census.snapshot)

  before = Census.snapshot
  20.times do
    client = Async::HTTP::Client.new(UPSTREAM)
    LEAKED << client
    client.get("/").read
  end
  Census.report("client per request", before, Census.snapshot)

  before = Census.snapshot
  20.times { SHARED.get("/") }
  Census.report("bodies never closed", before, Census.snapshot)

  upstream.stop
end
