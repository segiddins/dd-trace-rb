# require 'datadog/statsd'
require 'ddtrace'
# require 'datadog/appsec'

require 'opentracing'
require 'datadog/tracing'
require 'datadog/opentracer'


# Activate the Datadog tracer for OpenTracing
OpenTracing.global_tracer = Datadog::OpenTracer::Tracer.new(
  enabled: true,
  default_service: "my-service"
)

Datadog.configure do |c|
  c.diagnostics.debug = true #if Datadog::DemoEnv.feature?('debug')

  # c.tracing.instrument :faraday
  # c.tracing.instrument :http
  # c.tracing.instrument :rails
end
