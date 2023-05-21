require 'yaml'

require_relative 'schema/v01'

module Datadog
  module Tracing
    # TODO: Move me to a better namespace
    module Prototype
      module Schema
        def self.schema_path
          ENV['DD_TRACE_SCHEMA_FILE_PATH'] || './trace-schema.yaml'
        end

        def self.from_file(filepath = schema_path)
          file = nil

          begin
            file = File.open(filepath)
            new(file)
          ensure
            file.close
          end
        end

        def self.schema
          @schema ||= from_file
        end

        def self.mapper
          # TODO: Use mapper based on schema version
          @mapper ||= Schema::V01::SpanMapper.new(schema)
        end

        def self.new(stream)
          raw_data = stream.read
          data = YAML.load(raw_data)
          format = data['meta']['format']

          case format
          when 0.1
            Schema::V01.parse(data)
          else
            raise "Unsupported format '#{format}' for schema!"
          end
        end

        def self.snapshots_to_spans(snapshots)
          mapper.from_snapshots(snapshots)
        end
      end
    end
  end
end
