require "async/http"

module Census
  TRACKED = [Async::Pool::Controller, Async::HTTP::Client]

  class << self
    def snapshot
      GC.start

      {
        fds: Dir.children("/proc/#{Process.pid}/fd").size,
        pools: pools,
        objects: objects,
      }
    end

    def report(label, before, after)
      puts format("%-22s fds=%-5s pools=%-5s connections=%s", label, delta(before[:fds], after[:fds]), delta(before[:pools][:count], after[:pools][:count]), delta(before[:pools][:connections], after[:pools][:connections]))

      growth = after[:objects]
        .map { |klass, count| [klass, count - before[:objects].fetch(klass, 0)] }
        .reject { |_klass, change| change < 50 }
        .sort_by { |_klass, change| -change }
        .first(5)

      growth.each { |klass, change| puts format("  %-40s +%d", klass, change) }
    end

    private

      def delta(before, after) = "#{after}(#{format('%+d', after - before)})"

      def pools
        count = 0
        connections = 0

        ObjectSpace.each_object(Async::Pool::Controller) do |pool|
          count += 1
          connections += pool.size
        end

        {count: count, connections: connections}
      end

      def objects
        tally = Hash.new(0)

        ObjectSpace.each_object(Object) do |object|
          tally[object.class.to_s] += 1
        rescue StandardError
          nil
        end

        tally
      end
  end
end
