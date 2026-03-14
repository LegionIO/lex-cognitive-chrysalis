# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module CognitiveChrysalis
      module Actor
        class Advance < Legion::Extensions::Actors::Every
          def runner_class
            Legion::Extensions::CognitiveChrysalis::Runners::Reporting
          end

          def runner_function
            'tick_cooldown'
          end

          def time
            30
          end

          def run_now?
            false
          end

          def use_runner?
            false
          end

          def check_subtask?
            false
          end

          def generate_task?
            false
          end
        end
      end
    end
  end
end
