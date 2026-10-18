require "async"
require "async/http/protocol/http1"
require "socket"

client_io, server_io = UNIXSocket.pair

Async do |task|
	server = Async::HTTP::Protocol::HTTP1.server(server_io)

	server_task = task.async do
		server.each do |request|
			Protocol::HTTP::Response[200, {}, ["Hello #{request.path}"]]
		end
	end

	client = Async::HTTP::Protocol::HTTP1.client(client_io)
	response = client.call(Protocol::HTTP::Request["GET", "/", authority: "localhost"])

	p [response.status, response.read]

	client.close
	server_task.wait
end
