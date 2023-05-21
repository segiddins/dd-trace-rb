require_relative '../../../span'

module Datadog
  module Tracing
    # TODO: Move me to a better namespace
    module Prototype
      module Schema
        module V01
          class Mapper
            TOKEN_REGEX = /(<([A-Za-z0-9\-\_\.]+):([A-Za-z0-9\-\_\.]+)>)/

            attr_reader \
              :schema

            def initialize(schema)
              @schema = schema
            end

            def map_value(template, sources)
              return '' if template.nil? || template.empty?

              result = template.dup

              # Find all tokens
              tokens = template.scan(TOKEN_REGEX).uniq

              # For each token...
              tokens.each do |(token, source_name, key)|
                # Resolve the source
                source = sources[source_name]

                # Resolve the value
                value = source ? sources[source_name][key].to_s : ''

                # Replace the token
                result.gsub!(token, value)
              end

              result
            end
          end

          class SpanMapper < Mapper
            def from_snapshots(snapshots)
              result = []

              # Assumes snapshots are already grouped by span
              snapshots.each do |span_id, snapshots|
                # Don't map if there's no data
                next (puts "SKIP: No data"; nil) unless snapshots.any?

                # Don't map if there's no matching span
                # NOTE: This is naive. Will fail if the first snapshot
                #       emitted by a span isn't explicitly defined.
                next (puts "SKIP: No match #{snapshots.first.name}"; nil) unless span = self.schema.tracing.spans.from_source(snapshots.first.name)

                sources = span.sources.map do |name, source|
                  source = snapshots.find { |snapshot| snapshot.name == source }
                  puts "WARN: No source for #{span.name}:#{name}:#{source} in #{snapshots.map(&:name)}" unless source
                  [name, source]
                end.to_h

                # Don't map if there's no start or finish event
                next (puts "SKIP: No start/finish"; nil) unless sources['start'] && sources['finish']

                result << map_span(span, sources)
              end

              result
            end

            def map_span(span, sources)
              binding.pry if sources['start'] == 'grandparent.finish'
              Datadog::Tracing::Span.new(
                span.name,
                duration: sources['finish']['duration'],
                end_time: sources['finish']['end_time'],
                id: sources['start']['span_id'],
                meta: map_meta(span, sources),
                metrics: map_metrics(span, sources),
                parent_id: sources['start']['parent_id'],
                resource: map_value(span.attributes['resource'], sources),
                service: map_value(span.attributes['service'], sources),
                start_time: sources['start']['start_time'],
                status: sources['finish']['status'],
                type: map_value(span.attributes['type'], sources),
                trace_id: sources['start']['trace_id'],
                service_entry: sources['finish']['service_entry']
              )
            end

            def map_meta(span, sources)
              tags = {}

              span.tags.each do |key, template|
                value = map_value(template, sources)
                next unless value && !value.empty?

                tags[key] = value
              end

              tags
            end

            def map_metrics(span, sources)
              metrics = {}

              span.metrics.each do |key, template|
                value = map_value(template, sources)
                next unless value && !value.empty?

                metrics[key] = value.to_f
              end

              metrics
            end
          end
        end
      end
    end
  end
end
