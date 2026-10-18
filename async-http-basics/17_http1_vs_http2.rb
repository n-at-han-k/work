require "async"
require "async/http"

ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:19851")

SCENARIOS = [
	["http/1.1", Async::HTTP::Protocol::HTTP1, nil],
	["http/1.1 limit=1", Async::HTTP::Protocol::HTTP1, 1],
	["h2", Async::HTTP::Protocol::HTTP2, nil],
	["h2 limit=1", Async::HTTP::Protocol::HTTP2, 1],
]

Async do |task|
	server = Async::HTTP::Server.for(ENDPOINT, protocol: Async::HTTP::Protocol::HTTP) do |request|
		sleep 0.2
		Protocol::HTTP::Response[200, {}, ["socket #{request.peer.address.ip_port}"]]
	end.run

	SCENARIOS.each do |label, protocol, limit|
		client = Async::HTTP::Client.new(ENDPOINT, protocol: protocol, limit: limit)

		start = Async::Clock.now
		results = 5.times.map { Async { response = client.get("/"); [response.version, response.read] } }.map(&:wait)

		puts format("%-17s version=%-8s sockets=%d elapsed=%.2fs pool=%s", label, results.first[0], results.map(&:last).uniq.size, Async::Clock.now - start, client.pool)

		client.close
	end

	puts
	puts "pool starvation: body never closed"

	[Async::HTTP::Protocol::HTTP1, Async::HTTP::Protocol::HTTP2].each do |protocol|
		client = Async::HTTP::Client.new(ENDPOINT, protocol: protocol, limit: 1)
		held = client.get("/")

		begin
			task.with_timeout(1) { client.get("/").read }
			puts format("  %-26s second request succeeded", protocol)
		rescue Async::TimeoutError
			puts format("  %-26s second request blocked, pool=%s", protocol, client.pool)
		end

		held.close
		client.close
	end

	server.stop
end
