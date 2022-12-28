module Datadog
  module Tracing
    module Contrib
      module Rails
        class Runner
          def perform(code_or_file = nil, *command_argv)
            Tracing.trace(
              Ext::SPAN_RUNNER,
              service: service,
              tags: {
                Tracing::Metadata::Ext::TAG_COMPONENT => Ext::TAG_COMPONENT,
                Tracing::Metadata::Ext::TAG_OPERATION => Ext::TAG_OPERATION_RUNNER,
              }
            ) do |span|
              if code_or_file == '-'
                span.resource = '$stdin'
                span.set_tag(Ext::TAG_RUNNER_STDIN, 'true')
              elsif File.exist?(code_or_file)
                span.resource = code_or_file
                span.set_tag(Ext::TAG_RUNNER_FILE, file)
              else
                span.resource = '<inline>' # An arbitrary code snippet
                span.set_tag(Ext::TAG_RUNNER_CODE, code)
              end

              # Set analytics sample rate
              configuration = Datadog.configuration.tracing[:rails]
              if Contrib::Analytics.enabled?(configuration[:analytics_enabled])
                Contrib::Analytics.set_sample_rate(span, configuration[:analytics_sample_rate])
              end

              super
            end
          end
        end
      end
    end
  end
end
