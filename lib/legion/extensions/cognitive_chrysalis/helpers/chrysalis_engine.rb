# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      module Helpers
        class ChrysalisEngine
          attr_reader :active_cycles, :completed_cycles, :dissolution_inventory,
                      :emergence_events, :cooldown_remaining

          def initialize
            @active_cycles        = {}
            @completed_cycles     = []
            @dissolution_inventory = {}
            @emergence_events     = []
            @cooldown_remaining   = 0
          end

          def begin_transformation(trigger:, domain:, phases: [])
            return { success: false, reason: :max_cycles_reached } if total_cycles >= Constants::MAX_CYCLES
            return { success: false, reason: :cooldown_active, remaining: @cooldown_remaining } if @cooldown_remaining.positive?

            cycle = MetamorphicCycle.new_cycle(trigger: trigger, domain: domain, phases: phases)
            @active_cycles[cycle[:cycle_id]] = cycle

            Legion::Logging.debug "[chrysalis] began transformation cycle=#{cycle[:cycle_id][0..7]} domain=#{domain} trigger=#{trigger}"
            { success: true, cycle_id: cycle[:cycle_id], domain: domain }
          end

          def advance_cycle(cycle_id:)
            cycle = @active_cycles[cycle_id]
            return { success: false, reason: :not_found } unless cycle

            updated = MetamorphicCycle.advance!(cycle)
            @active_cycles[cycle_id] = updated

            complete_cycle!(cycle_id, updated) if %i[emerged failed].include?(updated[:status])

            prog = MetamorphicCycle.progress(updated).round(3)
            Legion::Logging.debug "[chrysalis] advanced cycle=#{cycle_id[0..7]} status=#{updated[:status]} progress=#{prog}"
            {
              success:           true,
              cycle_id:          cycle_id,
              status:            updated[:status],
              progress:          MetamorphicCycle.progress(updated),
              dissolution_depth: MetamorphicCycle.dissolution_depth(updated),
              emergence_score:   MetamorphicCycle.emergence_readiness(updated)
            }
          end

          def offline_capabilities(cycle_id:, capabilities: [])
            return { success: false, reason: :not_found } unless @active_cycles.key?(cycle_id)

            @dissolution_inventory[cycle_id] ||= []
            new_caps = capabilities.map(&:to_s) - @dissolution_inventory[cycle_id]
            @dissolution_inventory[cycle_id].concat(new_caps)

            { success: true, cycle_id: cycle_id, offline: @dissolution_inventory[cycle_id] }
          end

          def restore_capabilities(cycle_id:)
            removed = @dissolution_inventory.delete(cycle_id) || []
            { success: true, cycle_id: cycle_id, restored: removed }
          end

          def record_emergence(cycle_id:, insight: nil)
            cycle = @completed_cycles.find { |c| c[:cycle_id] == cycle_id }
            cycle ||= @active_cycles[cycle_id]
            return { success: false, reason: :not_found } unless cycle

            event = {
              event_id:   SecureRandom.uuid,
              cycle_id:   cycle_id,
              domain:     cycle[:domain],
              insight:    insight,
              emerged_at: Time.now.utc
            }
            @emergence_events << event

            Legion::Logging.info "[chrysalis] emergence recorded cycle=#{cycle_id[0..7]} domain=#{cycle[:domain]}"
            { success: true, event_id: event[:event_id] }
          end

          def transformation_history
            @completed_cycles.map do |c|
              {
                cycle_id:          c[:cycle_id],
                domain:            c[:domain],
                trigger:           c[:trigger],
                status:            c[:status],
                dissolution_depth: MetamorphicCycle.dissolution_depth(c),
                emergence_score:   MetamorphicCycle.emergence_readiness(c),
                transformed:       MetamorphicCycle.transformed?(c),
                completed_at:      c[:completed_at]
              }
            end
          end

          def most_transformed_domains
            domain_counts = @completed_cycles
                            .select { |c| MetamorphicCycle.transformed?(c) }
                            .group_by { |c| c[:domain] }
                            .transform_values(&:count)
            domain_counts.sort_by { |_, count| -count }.to_h
          end

          def metamorphic_readiness
            return 0.0 if @cooldown_remaining.positive?
            return 0.0 if @active_cycles.any?

            emerged_count = @completed_cycles.count { |c| MetamorphicCycle.transformed?(c) }
            base = emerged_count.zero? ? 0.5 : [0.5 + (emerged_count * 0.05), 1.0].min
            base.round(10)
          end

          def chrysalis_report
            {
              active_cycles:      @active_cycles.size,
              completed_cycles:   @completed_cycles.size,
              emergence_events:   @emergence_events.size,
              cooldown_remaining: @cooldown_remaining,
              readiness:          metamorphic_readiness,
              readiness_label:    Constants.label_for(Constants::READINESS_LABELS, metamorphic_readiness),
              dissolved_domains:  @dissolution_inventory.keys.size
            }
          end

          def tick_cooldown
            return unless @cooldown_remaining.positive?

            @cooldown_remaining -= 1
          end

          def total_cycles
            @active_cycles.size + @completed_cycles.size
          end

          private

          def complete_cycle!(cycle_id, cycle)
            @active_cycles.delete(cycle_id)
            @completed_cycles << cycle
            restore_capabilities(cycle_id: cycle_id) if cycle[:status] == :emerged
            @cooldown_remaining = Constants::COOLDOWN_CYCLES if cycle[:status] == :emerged
          end
        end
      end
    end
  end
end
