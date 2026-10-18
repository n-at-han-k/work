require "protocol/http"

request = Protocol::HTTP::Request["GET", "/index.html"]
response = Protocol::HTTP::Response[200, {"content-type" => "text/plain"}, ["Hello World"]]

p request.method, request.path
p response.status, response.read
