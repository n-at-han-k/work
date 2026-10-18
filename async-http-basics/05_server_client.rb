require "async"
require "async/http"

endpoint = Async::HTTP::Endpoint.parse("http://localhost:9292")

app = Protocol::HTTP::Middleware.for do |request|
	Protocol::HTTP::Response[200, {}, ["Hello #{request.path}"]]
end

Async do
	server = Async::HTTP::Server.new(app, endpoint)
	server_task = server.run

	client = Async::HTTP::Client.new(endpoint)
	response = client.call(Protocol::HTTP::Request["GET", "/"])

	p [response.status, response.read]

	client.close
	server_task.stop
end
