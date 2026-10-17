require "ratalada/async"

Unauthorized = Class.new(StandardError)

class Auth < Protocol::HTTP::Middleware
  def call(request)
    super
  rescue Unauthorized => e
    Protocol::HTTP::Response[401, {}, ["caught: #{e.message}"]]
  end
end

class Inner < Protocol::HTTP::Middleware
  def call(request)
    raise Unauthorized, "raised inside a handler returned by the block"
  end
end

app = Auth.new(
  Ratalada::Frontends::ProtocolRoutes.build(
    proc do |request|
      case request
      in {path: "/inner"} then Inner.for { |r| Protocol::HTTP::Response[200, {}, ["unused"]] }
      in {path: "/raise"} then Inner.new(Protocol::HTTP::Middleware::NotFound)
      end
    end
  )
)

puts "frontend: #{Ratalada.config.frontend}"
puts "rack?:    #{Ratalada.rack_frontend?}"
puts "app:      #{app.class} -> #{app.delegate.class}"
puts "is App a Middleware? #{app.delegate.is_a?(Protocol::HTTP::Middleware)}"
puts "does App have a delegate? #{app.delegate.respond_to?(:delegate)}"
puts

["/raise", "/nope"].each do |path|
  response = app.call(Protocol::HTTP::Request["GET", path])
  puts "#{path.ljust(7)} -> #{response.status} #{response.body&.join}"
end
