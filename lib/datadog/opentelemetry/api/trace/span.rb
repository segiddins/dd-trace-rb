# frozen_string_literal: true

module Datadog
  module OpenTelemetry
    module Trace
      # Stores associated Datadog entities to the OpenTelemetry Span.
      module Span
        attr_accessor :datadog_trace, :datadog_span

        # def set_attribute(key, value)
        #   @mutex.synchronize do
        #     if @ended
        #       OpenTelemetry.logger.warn('Calling set_attribute on an ended Span.')
        #     else
        #       @attributes ||= {}
        #       @attributes[key] = value
        #       trim_span_attributes(@attributes)
        #       @total_recorded_attributes += 1
        #     end
        #   end
        #   self
        # end
        # alias []= set_attribute

        ::OpenTelemetry::Trace::Span.prepend(self)
      end
    end
  end
end
