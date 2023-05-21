require 'spec_helper'

require 'datadog/tracing/prototype/snapshots'
require 'datadog/tracing/span_operation'

RSpec.describe Datadog::Tracing::Prototype::Snapshots do
  shared_context 'span operation' do
    let(:span_op) do
      Datadog::Tracing::SpanOperation.new(
        name,
        service: service,
        resource: resource,
        type: type,
        tags: tags
      )
    end

    let(:step) { :start }

    let(:name) { 'example.operation' }
    let(:service) { double('service') }
    let(:resource) { double('resource') }
    let(:type) { double('type') }

    let(:tags) { { tag => tag_value, metric => metric_value } }
    let(:tag) { 'string_tag' }
    let(:tag_value) { 'abc' }
    let(:metric) { 'num_metric' }
    let(:metric_value) { 123 }
  end

  describe '::span_op_to_snapshot' do
    include_context 'span operation'

    subject(:snapshot) { described_class.span_op_to_snapshot(span_op, step) }

    context 'given a SpanOperation' do
      it { is_expected.to be_a_kind_of(Datadog::Tracing::Prototype::Snapshot) }

      it do
        is_expected.to have_attributes(
          id: kind_of(Integer),
          name: "#{span_op.name}.#{step.to_s}",
          timestamp: kind_of(Integer),
          clock_time: kind_of(Float)
        )
      end

      it { expect(snapshot['parent_id']).to eq(span_op.parent_id) }
      it { expect(snapshot['resource']).to eq(span_op.resource) }
      it { expect(snapshot['service']).to eq(span_op.service) }
      it { expect(snapshot['span_id']).to eq(span_op.id) }
      it { expect(snapshot['status']).to eq(span_op.status) }
      it { expect(snapshot['trace_id']).to eq(span_op.trace_id) }
      it { expect(snapshot['type']).to eq(span_op.type) }
      it { expect(snapshot[tag]).to eq(tag_value) }
      it { expect(snapshot[metric]).to eq(metric_value) }
    end
  end

  describe 'SpanOperation behavior' do
    include_context 'span operation'

    context 'when started' do
      let(:start) { span_op.snapshots[0] }

      before { span_op.start }

      it { expect(span_op.snapshots).to have(1).items }

      it do
        expect(start).to have_attributes(name: "#{span_op.name}.start")
        expect(start['start_time']).to eq(span_op.start_time)
      end
    end

    context 'when finished' do
      let(:start) { span_op.snapshots[0] }
      let(:finish) { span_op.snapshots[1] }

      before { span_op.start; span_op.finish }

      it { expect(span_op.snapshots).to have(2).items }

      it do
        expect(start).to have_attributes(name: "#{span_op.name}.start")
        expect(start['start_time']).to eq(span_op.start_time)

        expect(finish).to have_attributes(name: "#{span_op.name}.finish")
        expect(finish['duration']).to eq(span_op.duration)
        expect(finish['end_time']).to eq(span_op.end_time)
      end
    end
  end

  describe 'Tracing behavior' do
    context 'given a trace with multiple spans' do
      subject(:trace) do
        tracer.trace('grandparent', service: 'my-app') do |grandparent|
          grandparent.resource = 'top-level'
          grandparent.set_tag('action', 'progenate')

          tracer.trace('parent', resource: 'mid-level') do |parent|
            parent.service = 'my-app'
            parent.set_tag('action', 'progenate')

            tracer.trace('child') do |child|
              child.service = 'my-db'
              child.resource = 'bottom-level'
              child.set_tag('action', 'thrive')
              child.set_tag('count', 5)
            end

            parent.set_tag('count', 30)
          end

          grandparent.set_tag('count', 60)
        end
      end

      let(:spans) { tracer.writer.spans(:keep) }

      before do
        ENV['DD_TRACE_SCHEMA_FILE_PATH'] = '/app/spec/datadog/tracing/prototype/dummy-schema.yaml'
      end

      it do
        trace
        expect(spans).to have(3).items
      end
    end
  end
end
