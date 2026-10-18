require "protocol/http"

class Traced < Protocol::HTTP::Body::Buffered
	def read
		chunk = super
		p [:read, chunk]
		chunk
	end

	def close(error = nil)
		p [:close, error]
		super
	end
end

p :consumed
Protocol::HTTP::Response[200, {}, Traced.wrap(["a", "b"])].read

p :ignored
Protocol::HTTP::Response[200, {}, Traced.wrap(["a", "b"])].status
