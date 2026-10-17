require "async"
require "async/http/server"
require "async/http/client"
require "async/http/endpoint"
require "ratalada/protocol_http_ext"
require "process/metrics"
require "memory/leak"

PORT = Integer(ENV.fetch("PORT", "9501"))
REQUESTS = Integer(ENV.fetch("REQUESTS", "200000"))
CONCURRENCY = Integer(ENV.fetch("CONCURRENCY", "50"))
HEY = ENV.fetch("HEY", "nix run nixpkgs#hey --")

class App
  def initialize(router)
    @router = router
  end

  def call(request)
    begin
      handler = @router.call(request)
    rescue NoMatchingPatternError
      handler = nil
    end
    respond(handler, request)
  end

  def close = nil

  private

  def respond(handler, request)
    case handler
    when nil
      Protocol::HTTP::Response[404, {"content-type" => "text/plain"}, ["not found"]]
    when String
      Protocol::HTTP::Response[200, {"content-type" => "text/plain"}, [handler]]
    when Protocol::HTTP::Body::Readable
      Protocol::HTTP::Response[200, {}, handler]
    when Array
      status, headers, body = handler
      Protocol::HTTP::Response[status, headers, body.is_a?(String) ? [body] : body]
    else
      if handler.respond_to?(:call)
        respond(handler.call(request), request)
      else
        handler
      end
    end
  end
end

APP = App.new(proc { |request| "ok" })
MONITOR = Memory::Leak::Monitor.new(Process.pid, threshold_size: 10 * 1048576, increase_limit: 3)

def memory = Process::Metrics::General.capture(pid: Process.pid).fetch(Process.pid).memory

def report(label)
  snapshot = memory

  puts format(
    "  %-8s rss=%6.1fMB anon=%6.1fMB ruby_heap=%5.1fMB maps=%4d",
    label,
    snapshot.resident_size / 1048576.0,
    snapshot.anonymous_size / 1048576.0,
    GC.stat[:heap_allocated_pages] * GC::INTERNAL_CONSTANTS[:HEAP_PAGE_SIZE] / 1048576.0,
    snapshot.map_count
  )
end

Thread.new do
  Async do
    Async::HTTP::Server.new(APP, Async::HTTP::Endpoint.parse("http://127.0.0.1:#{PORT}")).run
  end
end

sleep 1

Async do
  client = Async::HTTP::Client.new(Async::HTTP::Endpoint.parse("http://127.0.0.1:#{PORT}"))

  unless client.get("/").read == "ok"
    raise "port #{PORT} is serving something other than this example"
  end

  client.close
end

puts "original ProtocolRoutes::App (vendored from ratalada 4.0.0)"
report("before")
MONITOR.sample!

system("#{HEY} -n #{REQUESTS} -c #{CONCURRENCY} http://127.0.0.1:#{PORT}/")

MONITOR.sample!
report("after")

puts format(
  "  leak     current=%6.1fMB increases=%d/%d leaking=%p",
  MONITOR.current_size / 1048576.0,
  MONITOR.increase_count,
  MONITOR.increase_limit,
  MONITOR.leaking?
)
