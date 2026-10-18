require "protocol/http1"
require "io/stream"
require "socket"

client_io, server_io = UNIXSocket.pair

client = Protocol::HTTP1::Connection.new(IO::Stream(client_io), persistent: false)
server = Protocol::HTTP1::Connection.new(IO::Stream(server_io), persistent: false)

client.write_request("localhost", "GET", "/", "HTTP/1.1", Protocol::HTTP::Headers.new)
client.write_body("HTTP/1.1", nil)

authority, method, target, version, headers, body = server.read_request
p [authority, method, target]

server.write_response("HTTP/1.1", 200, Protocol::HTTP::Headers.new)
server.write_body("HTTP/1.1", Protocol::HTTP::Body::Buffered.wrap(["Hello"]))

version, status, reason, headers, body = client.read_response("GET")
p [status, body.join]
