require "async"
require "async/http"

UPSTREAM_ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:19821")
PROXY_ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:19822")

Async do
	upstream = Async::HTTP::Server.for(UPSTREAM_ENDPOINT) do |request|
		sleep request.path.delete("/").to_f
		Protocol::HTTP::Response[200, {}, ["socket #{request.peer.address.ip_port}"]]
	end.run

	client = Async::HTTP::Client.new(UPSTREAM_ENDPOINT)

	proxy = Async::HTTP::Server.for(PROXY_ENDPOINT) do |request|
		client.get(request.path)
	end.run

	front = Async::HTTP::Client.new(PROXY_ENDPOINT)
	start = Async::Clock.now

	tasks = ["/0.1", "/0.3", "/0.5"].map do |path|
		Async do
			result = front.get(path).read
			puts format("+%4.0fms %-7s %-13s upstream pool: %s", (Async::Clock.now - start) * 1000, path, result, client.pool)
		end
	end

	tasks.each(&:wait)

	puts format("        all done              upstream pool: %s", client.pool)

	front.close
	proxy.stop
	puts format("        proxy stopped         upstream pool: %s", client.pool)

	client.close
	puts format("        client.close          upstream pool: %s", client.pool)

	upstream.stop
end
