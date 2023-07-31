# frozen_string_literal: true

module Datadog
  module OpenTelemetry
    module Trace
      # Stores associated Datadog entities to the OpenTelemetry Span.
      module Span
        def set_attribute(key, value)
          res = super
          # Attributes can get dropped or their values truncated by `super`
          datadog_set_attribute(key)
          res
        end
        alias []= set_attribute

        def add_attributes(attributes)
          res = super
          # Attributes can get dropped or their values truncated by `super`
          attributes.each { |key, _| datadog_set_attribute(key) }
          res
        end

        private

        def datadog_set_attribute(key)
          if @attributes.key?(key)
            datadog_span.set_tag(key, @attributes[key])
          else
            datadog_span.clear_tag(key)
          end
        end

        ::OpenTelemetry::SDK::Trace::Span.prepend(self)
      end
    end
  end
end
