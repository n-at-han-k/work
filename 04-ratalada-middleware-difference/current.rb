require "ratalada/protocol_http_ext"

class Tail
  attr_reader :closes

  def initialize
    @closes = 0
  end

  def call(request) = Protocol::HTTP::Response[200, {}, ["tail answered #{request.path}"]]
  def close = @closes += 1
end

class App
  def initialize(router)
    @router = router
  end

  def call(request)
    begin
      handler = @router.call(request)
    rescue NoMatchingPatternError
      handler = nil
    end
    respond(handler, request)
  end

  def close = nil

  private

  def respond(handler, request)
    case handler
    when nil
      Protocol::HTTP::Response[404, {"content-type" => "text/plain"}, ["not found"]]
    when String
      Protocol::HTTP::Response[200, {"content-type" => "text/plain"}, [handler]]
    when Protocol::HTTP::Body::Readable
      Protocol::HTTP::Response[200, {}, handler]
    when Array
      status, headers, body = handler
      Protocol::HTTP::Response[status, headers, body.is_a?(String) ? [body] : body]
    else
      if handler.respond_to?(:call)
        respond(handler.call(request), request)
      else
        handler
      end
    end
  end
end

TAIL = Tail.new

APP = App.new(
  proc do |request|
    case request
    in {path: "/local"} then "answered locally"
    end
  end
)

puts "original ProtocolRoutes::App (vendored from ratalada 4.0.0)"
puts "  the tail cannot be attached: App.new takes a router only"
puts

["/local", "/unmatched"].each do |path|
  response = APP.call(Protocol::HTTP::Request["GET", path])
  puts format("  GET %-11s %d %s", path, response.status, response.body&.join)
end

puts
APP.close
puts format("  APP.close -> tail closes: %d", TAIL.closes)
