require_relative '../span_operation'
require_relative 'snapshot'
require_relative 'schema'

module Datadog
  module Tracing
    # TODO: Move me to a better namespace
    module Prototype
      module Snapshots
        def self.span_op_to_snapshot(
          span_op,
          name,
          data: nil
        )
          name = "#{span_op.name}.#{name}"

          # Set span_op attributes
          data ||= {}
          data.merge!(
            'parent_id' => span_op.parent_id,
            'resource' => span_op.resource,
            'span_id' => span_op.id,
            'status' => span_op.status,
            'trace_id' => span_op.trace_id
          )

          data['service'] = span_op.service unless span_op.service.nil?
          data['type'] = span_op.type unless span_op.type.nil?

          # Set span tags & metrics
          data.merge!(span_op.send(:meta))
          data.merge!(span_op.send(:metrics))

          Snapshot.new(name, data: data)
        end

        def self.snapshots_to_spans(snapshots)
          Schema.snapshots_to_spans(snapshots)
        end

        module SpanOperation
          def snapshots
            @snapshots ||= []
          end

          def start(start_time = nil)
            result = super

            take_start_snapshot

            result
          end

          def take_start_snapshot
            # Generate snapshot
            @start_snapshot ||= false

            unless @start_snapshot
              snapshot =  Prototype::Snapshots.span_op_to_snapshot(
                            self,
                            'start',
                            data: { 'start_time' => self.start_time }
                          )
              
              snapshots << snapshot
              @start_snapshot = true
            end
          end

          def take_finish_snapshot
            # Generate snapshot
            @finish_snapshot ||= false

            unless @finish_snapshot
              snapshot =  Prototype::Snapshots.span_op_to_snapshot(
                            self,
                            'finish',
                            data: {
                              'duration' => duration,
                              'end_time' => self.end_time,
                              'service_entry' => parent.nil? || (service && parent.service != service)
                            }
                          )
              
              snapshots << snapshot
              @finish_snapshot = true
            end
          end
        end

        module SpanOperation
          module Events
            module AfterFinish
              def initialize
                super

                subscribe(&method(:take_finish_snapshot))
              end

              def take_finish_snapshot(_span, span_op)
                span_op.take_finish_snapshot
              end
            end
          end
        end

        module TraceOperation
          def snapshots
            @snapshots ||= {}
          end

          def finish_span(span, span_op, parent)
            self.snapshots[span_op.id] = span_op.snapshots

            super
          end

          def flush!
            finished = finished?
    
            # Copy out completed spans
            original_spans = @spans.dup
            @spans = []

            # Copy out completed snapshots
            self.snapshots
            snapshots = @snapshots.dup
            @snapshots = {}

            # Build spans from snapshots
            spans = Prototype::Snapshots.snapshots_to_spans(snapshots)

            # binding.pry
    
            # Yield spans for single-span sampling
            spans = yield(spans) if block_given?
    
            # Use spans to build a trace
            build_trace(spans, !finished)#.tap { |t| binding.pry }
          end
        end

        # Add snapshot behavior to tracing
        Datadog::Tracing::SpanOperation.prepend(SpanOperation)
        Datadog::Tracing::SpanOperation::Events::AfterFinish.prepend(SpanOperation::Events::AfterFinish)
        Datadog::Tracing::TraceOperation.prepend(TraceOperation)
      end
    end
  end
end
