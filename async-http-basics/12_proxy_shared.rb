require "async"
require "async/http"

UPSTREAM_ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:19811")
PROXY_ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:19812")

Async do
	upstream = Async::HTTP::Server.for(UPSTREAM_ENDPOINT) do |request|
		sleep 0.2
		Protocol::HTTP::Response[200, {}, ["upstream socket #{request.peer.address.ip_port}"]]
	end.run

	[nil, 2, 1].each do |limit|
		client = Async::HTTP::Client.new(UPSTREAM_ENDPOINT, limit: limit)
		proxy = Async::HTTP::Server.for(PROXY_ENDPOINT) { |request| client.get(request.path) }.run
		front = Async::HTTP::Client.new(PROXY_ENDPOINT)

		start = Async::Clock.now
		results = 5.times.map { |i| Async { front.get("/#{i}").read } }.map(&:wait)

		puts format("limit=%-4s sockets=%d elapsed=%.2fs pool=%s", limit.inspect, results.uniq.size, Async::Clock.now - start, client.pool)
		results.each { |result| puts "  #{result}" }

		front.close
		client.close
		proxy.stop
	end

	upstream.stop
end
