require_relative '../../core/utils/safe_dup'
require_relative '../../core/utils/time'
require_relative '../utils'

module Datadog
  module Tracing
    # TODO: Move me to a better namespace
    module Prototype
      # An object that contains "state" at a given moment
      class Snapshot
        attr_reader \
          :id,
          :name,
          :timestamp,
          :clock_time

        def initialize(name, data: nil)
          @clock_time = Core::Utils::Time.get_time
          @data = (data || {}).dup.freeze
          @id = Tracing::Utils.next_id
          @name = Core::Utils::SafeDup.frozen_or_dup(name)
          @timestamp = Core::Utils::Time.now.utc.to_i
        end

        def [](key)
          @data[key]
        end

        def key?(key)
          @data.key?(key)
        end

        def to_h
          {
            id: @id,
            name: @name,
            timestamp: @timestamp,
            clock_time: @clock_time,
            data: @data
          }
        end
      end
    end
  end
end