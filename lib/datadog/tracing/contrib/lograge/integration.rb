require_relative '../integration'
require_relative 'configuration/settings'
require_relative 'patcher'

module Datadog
  module Tracing
    module Contrib
      module Lograge
        # Description of Lograge integration
        class Integration
          include Contrib::Integration

          MINIMUM_VERSION = Gem::Version.new('0.11.0')

          # @public_api Changing the integration name or integration options can cause breaking changes
          register_as :lograge

          def self.version
            Gem.loaded_specs['lograge'] && Gem.loaded_specs['lograge'].version
          end

          def self.loaded?
            !defined?(::Lograge::LogSubscribers::Base).nil?
          end

          def self.compatible?
            super && version >= MINIMUM_VERSION
          end

          def new_configuration
            Configuration::Settings.new
          end

          def patcher
            Patcher
          end

          def patch
            log_injection_enabled = Datadog.configuration.tracing.log_injection

            if !self.class.patchable? || !log_injection_enabled
              return {
                name: self.class.name,
                available: self.class.available?,
                loaded: self.class.loaded?,
                compatible: self.class.compatible?,
                patchable: self.class.patchable?,
                configured_enabled: log_injection_enabled
              }
            end

            patcher.patch
            true
          end
        end
      end
    end
  end
end
