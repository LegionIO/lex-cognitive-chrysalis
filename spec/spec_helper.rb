# frozen_string_literal: true

require 'legion/extensions/cognitive_chrysalis'

module Legion
  module Logging
    def self.debug(_msg); end
    def self.info(_msg); end
    def self.warn(_msg); end
    def self.error(_msg); end
  end

  module Extensions
    module Helpers
      module Lex; end
    end

    module Core; end
  end
end
