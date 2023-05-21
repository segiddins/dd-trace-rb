require 'spec_helper'

require 'datadog/tracing/prototype/schema'
require 'datadog/tracing/prototype/snapshot'

RSpec.describe Datadog::Tracing::Prototype::Schema do
  describe '::new' do
    subject(:schema) { described_class.new(stream) }
    let(:stream) { File.open('/app/spec/datadog/tracing/prototype/trace-schema.yaml') }
  
    after { stream.close }

    it do
      is_expected.to be_a_kind_of(described_class::V01::Document)
    end
  end

  describe '::snapshots_to_spans' do
    subject(:spans) { described_class.snapshots_to_spans(snapshots) }

    def new_snapshot_pair(
      trace_id = Tracing::Utils::TraceId.next_id,
      span_id = Tracing::Utils.next_id
    )
      [
        Datadog::Tracing::Prototype::Snapshot.new(
          'http.request.start',
          data: {
            'start_time' => 1684205552,
            'http.method' => 'GET',
            'http.status_code' => 200,
            'http.url' => '/product/abc',
            'out.host' => 'example.com',
            'out.port' => 80,
            'parent_id' => 0,
            'peer.hostname' => 'example.com',
            'peer.service' => 'shop-api',
            'resource' => 'GET',
            'service' => 'shop-api',
            'span_id' => span_id,
            'trace_id' => trace_id
          }
        ),
        Datadog::Tracing::Prototype::Snapshot.new(
          'http.request.finish',
          data: {
            'duration' => 0.241,
            'end_time' => 1684205552,
            'http.method' => 'GET',
            'http.status_code' => 200,
            'http.url' => '/product/abc',
            'out.host' => 'example.com',
            'out.port' => 80,
            'parent_id' => 0,
            'peer.hostname' => 'example.com',
            'peer.service' => 'shop-api',
            'resource' => 'GET',
            'service' => 'shop-api',
            'span_id' => span_id,
            'trace_id' => trace_id
          }
        )
      ]
    end

    let(:snapshots) do
      snaps = {}

      3.times do
        trace_id = Datadog::Tracing::Utils::TraceId.next_id
        span_id = Datadog::Tracing::Utils.next_id

        snaps[span_id] = new_snapshot_pair(trace_id, span_id)
      end

      snaps
    end

    before do
      ENV['DD_TRACE_SCHEMA_FILE_PATH'] = '/app/spec/datadog/tracing/prototype/trace-schema.yaml'
    end

    it do
      is_expected.to be_a_kind_of(described_class::V01::Document)
    end
  end
end
