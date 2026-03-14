# frozen_string_literal: true

require 'legion/extensions/cognitive_chrysalis/version'
require 'legion/extensions/cognitive_chrysalis/helpers/constants'
require 'legion/extensions/cognitive_chrysalis/helpers/transformation_phase'
require 'legion/extensions/cognitive_chrysalis/helpers/metamorphic_cycle'
require 'legion/extensions/cognitive_chrysalis/helpers/chrysalis_engine'
require 'legion/extensions/cognitive_chrysalis/runners/transformation'
require 'legion/extensions/cognitive_chrysalis/runners/reporting'

module Legion
  module Extensions
    module CognitiveChrysalis
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
