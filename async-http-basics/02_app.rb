require "protocol/http"

app = Protocol::HTTP::Middleware.for do |request|
	Protocol::HTTP::Response[200, {}, ["Hello #{request.path}"]]
end

p app.call(Protocol::HTTP::Request["GET", "/test"]).read
