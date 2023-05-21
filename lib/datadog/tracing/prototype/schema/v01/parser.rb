require_relative 'document'

module Datadog
  module Tracing
    # TODO: Move me to a better namespace
    module Prototype
      module Schema
        module V01
          class Parser
            def document_from_raw(data)
              Document.new(
                meta: meta_from_raw(data['meta']),
                tracing: tracing_from_raw(data['tracing'])
              )
            end

            def meta_from_raw(data)
              Meta.new(
                id: data['id'],
                version: data['version']
              )
            end

            def tracing_from_raw(data)
              Tracing.new(
                spans: spans_from_raw(data['spans'])
              )
            end

            def spans_from_raw(data)
              spans = data.map do |span_name, span_data|
                [span_name, span_from_raw(span_name, span_data)]
              end.to_h

              Spans.new(spans)
            end

            def span_from_raw(name, data)
              Span.new(
                name,
                sources: Span::Sources.new(data['sources']),
                attributes: Span::Attributes.new(data['attributes']),
                tags: Span::Tags.new(data['tags']),
                metrics: Span::Metrics.new(data['metrics'])
              )
            end
          end
        end
      end
    end
  end
end
