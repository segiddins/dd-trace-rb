require_relative '../map'

module Datadog
  module Tracing
    # TODO: Move me to a better namespace
    module Prototype
      module Schema
        module V01
          class Document
            attr_reader \
              :meta,
              :tracing

            def initialize(meta: nil, tracing: nil)
              @meta = meta || Meta.new
              @tracing = tracing || Tracing.new
            end
          end

          class Meta
            attr_reader \
              :format,
              :id,
              :version

            def initialize(id: nil, version: nil)
              @format = 0.1
              @id = id || 'default'
              @version = version || '1.0'
            end
          end

          class Tracing
            attr_reader \
              :spans

            def initialize(spans: nil)
              @spans = spans || Spans.new
            end
          end

          class Spans < Schema::Map
            def initialize(spans)
              super
              @spans_by_source = {}

              spans.values.each { |span| add_span_to_source_index(span) }
            end

            def add(name, span)
              super

              add_span_to_source_index(span)
            end

            def from_source(name)
              @spans_by_source[name]
            end

            private

            def add_span_to_source_index(span)
              span.sources.each do |_name, source|
                @spans_by_source[source] ||= span
              end
            end
          end

          class Span
            attr_reader \
              :name,
              :sources,
              :attributes,
              :tags,
              :metrics

            def initialize(
              name,
              sources:,
              attributes: nil,
              tags: nil,
              metrics: nil
            )
              @name = name
              @sources = sources
              @attributes = attributes
              @tags = tags
              @metrics = metrics
            end

            class Sources < Schema::Map; end

            class Attributes < Schema::Map; end

            class Tags < Schema::Map; end

            class Metrics < Schema::Map; end
          end
        end
      end
    end
  end
end
