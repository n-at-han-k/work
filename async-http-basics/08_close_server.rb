require "async"
require "async/http"

class Traced < Protocol::HTTP::Body::Buffered
	def read
		chunk = super
		p [:server_read, chunk]
		chunk
	end

	def close(error = nil)
		p [:server_close, error]
		super
	end
end

endpoint = Async::HTTP::Endpoint.parse("http://localhost:9292")

Async do
	server_task = Async::HTTP::Server.for(endpoint) do |request|
		Protocol::HTTP::Response[200, {}, Traced.wrap(["Hello"])]
	end.run

	client = Async::HTTP::Client.new(endpoint)
	p [:client_got, client.get("/").read]

	client.close
	server_task.stop
end
