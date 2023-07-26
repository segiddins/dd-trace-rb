require_relative '../core/environment/identity'
require_relative '../core/utils'

require_relative 'event'
require_relative 'metadata/tagging'
require_relative 'sampling/ext'
require_relative 'span_operation'
require_relative 'trace_digest'
require_relative 'trace_segment'
require_relative 'utils'

module Datadog
  module Tracing
    class TraceOperation
      def finish_span(span, span_op, parent)
        begin
          # Save finished span & root span
          @spans << span unless span.nil?

          # Deactivate the span, re-activate parent.
          deactivate_span!(span_op)

          # Set finished, to signal root span has completed.
          @finished = true if span_op == root_span

          # Update active span count
          @active_span_count -= 1

          # Publish :span_finished event
          events.span_finished.publish(span, self)

          puts "events.trace_finished.publish(self) if finished?: #{finished?}"
          STDOUT.flush

          # Publish :trace_finished event
          events.trace_finished.publish(self) if finished?
        rescue StandardError => e
          Datadog.logger.debug { "Error finishing span on trace: #{e} Backtrace: #{e.backtrace.first(3)}" }
        end
      end
    end
  end
end
