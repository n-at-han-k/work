require "async"
require "async/http/server"
require "async/http/client"
require "async/http/endpoint"
require "process/metrics"

ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:9296")

def memory
  Process::Metrics::General.capture(pid: Process.pid).fetch(Process.pid).memory
end

def report(label)
  snapshot = memory
  heap = GC.stat[:heap_allocated_pages] * GC::INTERNAL_CONSTANTS[:HEAP_PAGE_SIZE]

  puts format(
    "  %-22s rss=%6.1fMB anon=%6.1fMB ruby_heap=%5.1fMB maps=%4d",
    label,
    snapshot.resident_size / 1048576.0,
    snapshot.anonymous_size / 1048576.0,
    heap / 1048576.0,
    snapshot.map_count
  )
end

Async do |task|
  server = Async::HTTP::Server.for(ENDPOINT) do |request|
    Protocol::HTTP::Response[200, {}, ["read #{request.read.to_s.bytesize} bytes"]]
  end

  listening = task.async { server.run }

  body = "x" * 1048576

  puts "Async::HTTP::Server.for, handler retains nothing"
  puts

  report("before any requests")

  client = Async::HTTP::Client.new(ENDPOINT)
  100.times { client.post("/", {}, [body]).read }
  report("100 sequential")

  concurrent = 50.times.map do
    task.async do
      Async::HTTP::Client.new(ENDPOINT).then do |own|
        own.post("/", {}, [body]).read
        own.close
      end
    end
  end
  concurrent.each(&:wait)
  report("50 concurrent clients")

  GC.start
  report("after GC.start")

  client.close
  listening.stop
end
