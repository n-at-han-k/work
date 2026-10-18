require "async"
require "async/http"

endpoint = Async::HTTP::Endpoint.parse("http://localhost:9292")

Async do |task|
	server_task = Async::HTTP::Server.for(endpoint) do |request|
		body = Protocol::HTTP::Body::Writable.new

		Async do
			100.times do |i|
				body.write("chunk #{i}\n")
				sleep 0.01
			end
		rescue => error
			p [:producer_stopped, error.class]
		end

		Protocol::HTTP::Response[200, {}, body]
	end.run

	client = Async::HTTP::Client.new(endpoint)
	response = client.get("/")

	p [:client_read, response.body.read]
	response.close

	sleep 0.5

	client.close
	server_task.stop
end
