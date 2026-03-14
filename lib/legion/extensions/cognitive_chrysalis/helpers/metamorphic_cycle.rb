# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveChrysalis
      module Helpers
        module MetamorphicCycle
          STATUSES = %i[incubating active transforming emerged failed].freeze

          module_function

          def new_cycle(trigger:, domain:, phases: [])
            raise ArgumentError, "invalid domain: #{domain}" unless Constants::TRANSFORMATION_DOMAINS.include?(domain.to_sym)

            {
              cycle_id:            SecureRandom.uuid,
              trigger:             trigger.to_s,
              domain:              domain.to_sym,
              phases:              phases,
              current_phase_index: 0,
              status:              :incubating,
              started_at:          nil,
              completed_at:        nil,
              dissolution_depth:   0.0,
              emergence_score:     0.0
            }
          end

          def advance!(cycle)
            return cycle if %i[emerged failed].include?(cycle[:status])

            updated = cycle.dup
            updated[:phases] = cycle[:phases].dup
            updated[:started_at] ||= Time.now.utc
            updated[:status] = :active if updated[:status] == :incubating

            current = updated[:phases][updated[:current_phase_index]]
            return updated unless current

            advanced_phase = TransformationPhase.advance_phase(current)
            updated[:phases][updated[:current_phase_index]] = advanced_phase

            update_dissolution_depth!(updated, advanced_phase)
            update_emergence_score!(updated, advanced_phase)

            handle_phase_completion!(updated) if TransformationPhase.complete?(advanced_phase)

            updated
          end

          def current_phase(cycle)
            cycle[:phases][cycle[:current_phase_index]]
          end

          def progress_in_phase(cycle)
            phase = current_phase(cycle)
            return 0.0 unless phase

            TransformationPhase.progress(phase)
          end

          def progress(cycle)
            return 0.0 if cycle[:phases].empty?

            completed = cycle[:phases].count { |p| TransformationPhase.complete?(p) }
            in_progress = progress_in_phase(cycle) / cycle[:phases].size
            base = (completed.to_f / cycle[:phases].size).round(10)
            (base + in_progress).clamp(0.0, 1.0).round(10)
          end

          def transformed?(cycle)
            cycle[:status] == :emerged && cycle[:emergence_score] >= Constants::EMERGENCE_THRESHOLD
          end

          def dissolution_depth(cycle)
            cycle[:dissolution_depth].round(10)
          end

          def emergence_readiness(cycle)
            cycle[:emergence_score].round(10)
          end

          def status_label(cycle)
            cycle[:status]
          end

          private_class_method def self.update_dissolution_depth!(cycle, phase)
            return unless %i[dissolution chrysalis].include?(phase[:name])

            gain = (Constants::DISSOLUTION_RATE * phase[:intensity]).round(10)
            cycle[:dissolution_depth] = (cycle[:dissolution_depth] + gain).clamp(0.0, 1.0).round(10)
          end

          private_class_method def self.update_emergence_score!(cycle, phase)
            return unless %i[reformation emergence].include?(phase[:name])

            gain = (Constants::REFORMATION_RATE * phase[:intensity]).round(10)
            cycle[:emergence_score] = (cycle[:emergence_score] + gain).clamp(0.0, 1.0).round(10)
          end

          private_class_method def self.handle_phase_completion!(cycle)
            next_index = cycle[:current_phase_index] + 1

            if next_index >= cycle[:phases].size
              cycle[:status] = :emerged
              cycle[:completed_at] = Time.now.utc
            else
              cycle[:current_phase_index] = next_index
              cycle[:status] = :transforming
            end
          end
        end
      end
    end
  end
end
