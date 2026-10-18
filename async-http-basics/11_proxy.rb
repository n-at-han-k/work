require "async"
require "async/http"

UPSTREAM_PORT = 19801
PROXY_PORT = 19802

UPSTREAM_ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:#{UPSTREAM_PORT}")
PROXY_ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:#{PROXY_PORT}")

Async do
	upstream = Async::HTTP::Server.for(UPSTREAM_ENDPOINT) do |request|
		sleep 0.2
		Protocol::HTTP::Response[200, {}, ["upstream socket #{request.peer.address.ip_port}"]]
	end.run

	client = Async::HTTP::Client.new(UPSTREAM_ENDPOINT)

	proxy = Async::HTTP::Server.for(PROXY_ENDPOINT) do |request|
		client.get(request.path)
	end.run

	front = Async::HTTP::Client.new(PROXY_ENDPOINT)

	puts "5 concurrent"
	tasks = 5.times.map { |i| Async { front.get("/#{i}").read } }
	sleep 0.05
	puts "  mid-flight pool: #{client.pool}"
	tasks.each { |task| puts "  #{task.wait}" }
	puts "  after drain:     #{client.pool}"

	puts "5 sequential"
	5.times { |i| puts "  #{front.get("/#{i}").read}" }
	puts "  after drain:     #{client.pool}"

	puts "close"
	front.close
	client.close
	puts "  after close:     #{client.pool}"

	proxy.stop
	upstream.stop
end
