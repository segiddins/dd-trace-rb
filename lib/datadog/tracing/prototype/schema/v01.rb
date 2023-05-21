require_relative 'v01/parser'
require_relative 'v01/mapper'

module Datadog
  module Tracing
    # TODO: Move me to a better namespace
    module Prototype
      module Schema
        module V01
          def self.parse(data)
            Parser.new.document_from_raw(data)
          end
        end
      end
    end
  end
end
