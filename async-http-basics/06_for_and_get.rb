require "async"
require "async/http"

endpoint = Async::HTTP::Endpoint.parse("http://localhost:9292")

Async do
	server_task = Async::HTTP::Server.for(endpoint) do |request|
		Protocol::HTTP::Response[200, {}, ["Hello #{request.path}"]]
	end.run

	client = Async::HTTP::Client.new(endpoint)
	response = client.get("/")

	p [response.status, response.read]

	client.close
	server_task.stop
end
