# frozen_string_literal: true

require 'legion/extensions/cognitive_chrysalis/helpers/constants'
require 'legion/extensions/cognitive_chrysalis/helpers/transformation_phase'
require 'legion/extensions/cognitive_chrysalis/helpers/metamorphic_cycle'
require 'legion/extensions/cognitive_chrysalis/helpers/chrysalis_engine'
require 'legion/extensions/cognitive_chrysalis/runners/transformation'
require 'legion/extensions/cognitive_chrysalis/runners/reporting'

module Legion
  module Extensions
    module CognitiveChrysalis
      class Client
        include Legion::Extensions::CognitiveChrysalis::Runners::Transformation
        include Legion::Extensions::CognitiveChrysalis::Runners::Reporting

        attr_reader :engine

        def initialize(engine: nil, **)
          @default_engine = engine || Helpers::ChrysalisEngine.new
        end

        private

        attr_reader :default_engine
      end
    end
  end
end
