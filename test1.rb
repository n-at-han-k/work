# To reach 681MB of anon with ~12KB/fiber you'd need ~55,000 live fibers, and FDSize 256 rules that out. It's the Ruby object heap — real retained objects. You're right that a small app shouldn't do that, which makes it a retention bug, not an allocator artifact.

def rss = Integer(File.read("/proc/self/status")[/VmRSS:\s*(\d+)/, 1])
def vsz = Integer(File.read("/proc/self/status")[/VmSize:\s*(\d+)/, 1])

def report(label)
  puts format("  %-34s rss=%7.1f MB  vsize=%8.1f MB", label, rss / 1024.0, vsz / 1024.0)
end

N = Integer(ENV.fetch("N", "200"))

puts "RUBY_FIBER_VM_STACK_SIZE=#{ENV["RUBY_FIBER_VM_STACK_SIZE"] || "(default 131072)"}"
puts "RUBY_FIBER_MACHINE_STACK_SIZE=#{ENV["RUBY_FIBER_MACHINE_STACK_SIZE"] || "(default 262144)"}"

report("baseline")

fibers = N.times.map { Fiber.new { Fiber.yield } }
report("#{N} fibers created (not resumed)")

fibers.each(&:resume)
report("#{N} fibers resumed (alive)")

fibers.each { |f| f.resume if f.alive? }
report("#{N} fibers finished")

fibers = nil
GC.start
report("dropped + GC.start")

again = N.times.map { Fiber.new { Fiber.yield } }
again.each(&:resume)
report("#{N} NEW fibers (reuse from pool?)")
