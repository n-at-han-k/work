require "ratalada/async"
require "async/http/client"
require "async/http/endpoint"
require "process/metrics"
require "memory/leak"

PORT = Integer(ENV.fetch("PORT", "9601"))
ROUNDS = Integer(ENV.fetch("ROUNDS", "4"))
REQUESTS = Integer(ENV.fetch("REQUESTS", "50000"))
CONCURRENCY = Integer(ENV.fetch("CONCURRENCY", "50"))
HEY = ENV.fetch("HEY", "nix run nixpkgs#hey --")

MONITOR = Memory::Leak::Monitor.new(Process.pid, threshold_size: 10 * 1048576, increase_limit: 3)

def memory = Process::Metrics::General.capture(pid: Process.pid).fetch(Process.pid).memory

def report(label)
  snapshot = memory

  puts format(
    "  %-9s rss=%6.1fMB anon=%6.1fMB ruby_heap=%5.1fMB maps=%4d increases=%d/%d leaking=%p",
    label,
    snapshot.resident_size / 1048576.0,
    snapshot.anonymous_size / 1048576.0,
    GC.stat[:heap_allocated_pages] * GC::INTERNAL_CONSTANTS[:HEAP_PAGE_SIZE] / 1048576.0,
    snapshot.map_count,
    MONITOR.increase_count,
    MONITOR.increase_limit,
    MONITOR.leaking?
  )
end

Thread.new do
  Server.run(host: "127.0.0.1", port: PORT) do |request|
    case request
    in ["GET", "/"] then "ok"
    end
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

puts "frontend: #{Ratalada.config.frontend} (rack? #{Ratalada.rack_frontend?})"
MONITOR.sample!
report("before")

ROUNDS.times do |round|
  system("#{HEY} -n #{REQUESTS} -c #{CONCURRENCY} http://127.0.0.1:#{PORT}/ > /dev/null")
  MONITOR.sample!
  report("round #{round}")
end

GC.start
MONITOR.sample!
report("after GC")
