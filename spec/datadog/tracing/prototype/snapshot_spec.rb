require 'spec_helper'

require 'datadog/tracing/prototype/snapshot'

RSpec.describe Datadog::Tracing::Prototype::Snapshot do
  subject(:snapshot) { described_class.new(name, data: data) }

  let(:name) { 'example.operation.start' }
  let(:data) { {} }

  describe '#initialize' do
    it do
      is_expected.to have_attributes(
        id: kind_of(Integer),
        name: name,
        timestamp: kind_of(Integer),
        clock_time: kind_of(Float)
      )
    end
  end
end
