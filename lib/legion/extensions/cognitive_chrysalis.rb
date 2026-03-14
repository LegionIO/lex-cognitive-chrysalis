# frozen_string_literal: true

require 'securerandom'
require 'legion/extensions/cognitive_chrysalis/version'
require 'legion/extensions/cognitive_chrysalis/helpers/constants'
require 'legion/extensions/cognitive_chrysalis/helpers/chrysalis'
require 'legion/extensions/cognitive_chrysalis/helpers/cocoon'
require 'legion/extensions/cognitive_chrysalis/helpers/metamorphosis_engine'
require 'legion/extensions/cognitive_chrysalis/runners/cognitive_chrysalis'
require 'legion/extensions/cognitive_chrysalis/client'

module Legion
  module Extensions
    module CognitiveChrysalis
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
