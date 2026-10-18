require "protocol/http"

body = Protocol::HTTP::Body::Writable.new
body.write("a")
p body.read
body.close

begin
	body.write("b")
rescue => error
	p error
end

body = Protocol::HTTP::Body::Writable.new
body.close(RuntimeError.new("boom"))

begin
	body.read
rescue => error
	p error
end
