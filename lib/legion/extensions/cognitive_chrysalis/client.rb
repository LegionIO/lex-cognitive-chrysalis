# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      class Client
        include Runners::CognitiveChrysalis

        attr_reader :engine

        def initialize(**)
          @engine         = Helpers::MetamorphosisEngine.new
          @default_engine = @engine
        end
      end
    end
  end
end
