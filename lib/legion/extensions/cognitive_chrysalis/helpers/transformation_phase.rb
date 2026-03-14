# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      module Helpers
        module TransformationPhase
          module_function

          def new_phase(name:, duration_ticks:, intensity: Constants::DEFAULT_INTENSITY,
                        domain: :cognitive, description: '')
            raise ArgumentError, "invalid phase name: #{name}" unless Constants::PHASE_NAMES.include?(name.to_sym)
            raise ArgumentError, "invalid domain: #{domain}" unless Constants::TRANSFORMATION_DOMAINS.include?(domain.to_sym)

            {
              name:           name.to_sym,
              duration_ticks: duration_ticks.to_i.clamp(1, 10_000),
              intensity:      intensity.to_f.clamp(0.0, 1.0).round(10),
              domain:         domain.to_sym,
              description:    description.to_s,
              ticks_elapsed:  0,
              started_at:     nil,
              completed_at:   nil
            }
          end

          def advance_phase(phase)
            return phase if complete?(phase)

            updated = phase.dup
            updated[:ticks_elapsed] += 1
            updated[:started_at] ||= Time.now.utc
            updated[:completed_at] = Time.now.utc if updated[:ticks_elapsed] >= updated[:duration_ticks]
            updated
          end

          def complete?(phase)
            phase[:ticks_elapsed] >= phase[:duration_ticks]
          end

          def progress(phase)
            return 1.0 if phase[:duration_ticks].zero?

            (phase[:ticks_elapsed].to_f / phase[:duration_ticks]).clamp(0.0, 1.0).round(10)
          end

          def intensity_label(phase)
            Constants.label_for(Constants::INTENSITY_LABELS, phase[:intensity])
          end
        end
      end
    end
  end
end
