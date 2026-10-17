require "opentelemetry/sdk"
require "opentelemetry-metrics-sdk"
require "process/metrics"
require "memory/leak"

INTERVAL = Integer(ENV.fetch("INTERVAL", "3000"))
ROUNDS = Integer(ENV.fetch("ROUNDS", "4"))
CHUNK = Integer(ENV.fetch("CHUNK", "50")) * 1048576

OpenTelemetry::SDK.configure do |config|
  config.service_name = "work-runtime-metrics"
end

READER = OpenTelemetry::SDK::Metrics::Export::PeriodicMetricReader.new(
  export_interval_millis: INTERVAL,
  exporter: OpenTelemetry::SDK::Metrics::Export::ConsoleMetricPullExporter.new
)

OpenTelemetry.meter_provider.add_metric_reader(READER)

METER = OpenTelemetry.meter_provider.meter("runtime")

MONITOR = Memory::Leak::Monitor.new(
  Process.pid,
  threshold_size: 10 * 1048576,
  increase_limit: 3
)

GC.stat.each_key do |key|
  METER.create_observable_gauge(
    "gc_#{key}",
    callback: proc { GC.stat[key] },
    description: "GC.stat[:#{key}]"
  )
end

Process::Metrics::Memory.members.each do |member|
  METER.create_observable_gauge(
    "process_memory_#{member}",
    unit: member.to_s.end_with?("size") ? "By" : "1",
    callback: proc { Process::Metrics::General.capture(pid: Process.pid).fetch(Process.pid).memory&.public_send(member) },
    description: "Process::Metrics::Memory##{member}"
  )
end

METER.create_observable_gauge(
  "memory_leak_current_size",
  unit: "By",
  callback: proc { MONITOR.current_size },
  description: "Memory::Leak::Monitor#current_size"
)

METER.create_observable_gauge(
  "memory_leak_increase_count",
  callback: proc { MONITOR.increase_count },
  description: "Memory::Leak::Monitor#increase_count"
)

METER.create_observable_gauge(
  "memory_leak_leaking",
  callback: proc { MONITOR.leaking? ? 1 : 0 },
  description: "Memory::Leak::Monitor#leaking?"
)

RETAINED = []

MONITOR.sample!

ROUNDS.times do
  RETAINED << ("x" * CHUNK)
  MONITOR.sample!
  sleep(INTERVAL / 1000.0)
end

OpenTelemetry.meter_provider.shutdown
