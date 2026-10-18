require "protocol/http"

BODY_CLOSES = Hash.new(0)

class Traced < Protocol::HTTP::Body::Buffered
  def initialize(chunks, label)
    super(chunks)
    @label = label
  end

  def close(error = nil)
    BODY_CLOSES[@label] += 1
    super
  end
end

class Tail
  attr_reader :closes

  def initialize
    @read, @write = IO.pipe
    @closes = 0
  end

  def call(request) = Protocol::HTTP::Response[200, {}, ["tail answered #{request.path}"]]

  def open? = !@write.closed?

  def close
    @closes += 1
    @read.close
    @write.close
  end
end

class Logging < Protocol::HTTP::Middleware
  def call(request) = super
end

class Chained < Protocol::HTTP::Middleware
  def initialize(delegate, label)
    super(delegate)
    @label = label
  end

  def call(request)
    return super if request.path == "/unmatched"

    Protocol::HTTP::Response[200, {}, Traced.new(["answered locally"], @label)]
  end
end

class DeadEnd
  def initialize(delegate, label)
    @delegate = delegate
    @label = label
  end

  def call(request)
    return @delegate.call(request) if request.path == "/unmatched"

    Protocol::HTTP::Response[200, {}, Traced.new(["answered locally"], @label)]
  end

  def close = nil
end

CHAINED_TAIL = Tail.new
DEADEND_TAIL = Tail.new

CHAINED = Logging.new(Chained.new(CHAINED_TAIL, :chained))
DEADEND = Logging.new(DeadEnd.new(DEADEND_TAIL, :deadend))

def exercise(label, app)
  ["/local", "/unmatched"].each do |path|
    response = app.call(Protocol::HTTP::Request["GET", path])
    puts format("  GET %-11s %d %s", path, response.status, response.read)
  end
end

puts "per-request: identical"
puts " chained"
exercise(:chained, CHAINED)
puts " deadend"
exercise(:deadend, DEADEND)
puts format("  response bodies closed: chained=%d deadend=%d", BODY_CLOSES[:chained], BODY_CLOSES[:deadend])

puts
puts "shutdown: not identical"
CHAINED.close
DEADEND.close
puts format("  chained  tail.closes=%d pipe_open=%p", CHAINED_TAIL.closes, CHAINED_TAIL.open?)
puts format("  deadend  tail.closes=%d pipe_open=%p", DEADEND_TAIL.closes, DEADEND_TAIL.open?)

puts
puts format("  fds still held by the process: %d", ObjectSpace.each_object(IO).count { |io| !io.closed? })
