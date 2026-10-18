require "async"
require "async/http"

UPSTREAM = Async::HTTP::Endpoint.parse("http://127.0.0.1:19841")
PROXY = Async::HTTP::Endpoint.parse("http://127.0.0.1:19842")

START = Async::Clock.now

def log(message) = puts(format("+%4.0fms %s", (Async::Clock.now - START) * 1000, message))

class Trace < Protocol::HTTP::Body::Wrapper
	def initialize(body, label)
		super(body)
		@label = label
	end

	def read
		chunk = super
		log("    #{@label} read #{chunk.inspect}")
		chunk
	end

	def close(error = nil)
		log("    #{@label} close #{error.inspect}")
		super
	end
end

Async do
	upstream = Async::HTTP::Server.for(UPSTREAM) do |request|
		log("UPSTREAM  got request object=#{request.object_id} body=#{request.body.class}")

		body = Protocol::HTTP::Body::Writable.new

		Async do
			2.times do |i|
				body.write("down #{i}\n")
				sleep 0.15
			end
			body.close_write
		end

		log("UPSTREAM  responding before reading the request body")
		Protocol::HTTP::Response[200, {}, body]
	end.run

	client = Async::HTTP::Client.new(UPSTREAM)

	proxy = Async::HTTP::Server.for(PROXY) do |request|
		log("PROXY     downstream request object=#{request.object_id} body=#{request.body.class}")

		upstream_request = Protocol::HTTP::Request["POST", request.path, body: Trace.new(request.body, "up-req-body")]
		log("PROXY     upstream request  object=#{upstream_request.object_id}")

		response = client.call(upstream_request)
		log("PROXY     upstream response object=#{response.object_id} status=#{response.status}")

		response.body = Trace.new(response.body, "up-res-body")
		log("PROXY     returning         object=#{response.object_id}")

		response
	end.run

	front = Async::HTTP::Client.new(PROXY)

	upload = Protocol::HTTP::Body::Writable.new
	Async do
		2.times do |i|
			upload.write("up #{i}\n")
			sleep 0.15
		end
		upload.close_write
		log("CLIENT    upload finished")
	end

	response = front.post("/x", body: upload)
	log("CLIENT    response object=#{response.object_id} status=#{response.status}")

	while chunk = response.body.read
		log("CLIENT    read #{chunk.inspect}")
	end

	response.close
	log("CLIENT    response closed")

	sleep 0.1
	front.close
	client.close
	proxy.stop
	upstream.stop
end
