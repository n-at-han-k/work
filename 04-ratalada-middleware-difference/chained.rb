require "ratalada/protocol_http_ext"

class Tail
  attr_reader :closes

  def initialize
    @closes = 0
  end

  def call(request) = Protocol::HTTP::Response[200, {}, ["tail answered #{request.path}"]]
  def close = @closes += 1
end

class App < Protocol::HTTP::Middleware
  def self.build(router, delegate = Protocol::HTTP::Middleware::NotFound) = new(delegate, router)

  def initialize(delegate, router)
    super(delegate)
    @router = router
  end

  def call(request)
    begin
      handler = @router.call(request)
    rescue NoMatchingPatternError
      handler = nil
    end

    case handler
    when nil
      super
    when Protocol::HTTP::Response
      handler
    when String
      Protocol::HTTP::Response[200, {"content-type" => "text/plain"}, [handler]]
    when Protocol::HTTP::Body::Readable
      Protocol::HTTP::Response[200, {}, handler]
    else
      handler.call(request)
    end
  end
end

TAIL = Tail.new

APP = App.build(
  proc do |request|
    case request
    in {path: "/local"} then "answered locally"
    end
  end,
  TAIL
)

puts "App as a Protocol::HTTP::Middleware with a delegate tail"
puts format("  chain: %s -> %s", APP.class, APP.delegate.class)
puts

["/local", "/unmatched"].each do |path|
  response = APP.call(Protocol::HTTP::Request["GET", path])
  puts format("  GET %-11s %d %s", path, response.status, response.body&.join)
end

puts
APP.close
puts format("  APP.close -> tail closes: %d", TAIL.closes)
