module Datadog
  module Tracing
    # TODO: Move me to a better namespace
    module Prototype
      module Schema
        class Map
          def initialize(data)
            @data = data || {}
          end

          def [](key)
            @data[key]
          end

          def include?(key)
            @data.key?(key)
          end

          def add(key, value)
            @data[key] = value
          end

          def each(&block)
            @data.each(&block)
          end

          def map(&block)
            @data.map(&block)
          end
        end
      end
    end
  end
end
