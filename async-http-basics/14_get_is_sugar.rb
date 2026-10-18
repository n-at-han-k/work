require "async"
require "async/http"

ENDPOINT = Async::HTTP::Endpoint.parse("http://127.0.0.1:19831")

Async do
	server = Async::HTTP::Server.for(ENDPOINT) do |request|
		Protocol::HTTP::Response[200, {}, ["socket #{request.peer.address.ip_port}"]]
	end.run

	client = Async::HTTP::Client.new(ENDPOINT)

	3.times do
		response = client.get("/")
		puts format("get   response=%d body=%d %s", response.object_id, response.body.object_id, response.read)
	end

	3.times do
		request = Protocol::HTTP::Request["GET", "/"]
		response = client.call(request)
		puts format("call  request=%d  response=%d %s", request.object_id, response.object_id, response.read)
	end

	puts "pool: #{client.pool}"

	client.close
	server.stop
end
