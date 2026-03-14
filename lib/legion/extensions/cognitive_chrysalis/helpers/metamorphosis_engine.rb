# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      module Helpers
        class MetamorphosisEngine
          def initialize
            @chrysalises = {}
            @cocoons     = {}
            @sheltered   = {} # chrysalis_id => cocoon_id
          end

          def create_chrysalis(chrysalis_type:, content:, **)
            return { success: false, reason: :capacity_exceeded } if @chrysalises.size >= Helpers::Constants::MAX_CHRYSALISES

            c = Chrysalis.new(chrysalis_type: chrysalis_type, content: content)
            @chrysalises[c.id] = c
            { success: true, chrysalis: c.to_h }
          end

          def create_cocoon(environment:, **)
            cocoon = Cocoon.new(environment: environment)
            @cocoons[cocoon.id] = cocoon
            { success: true, cocoon: cocoon.to_h }
          end

          def spin(chrysalis_id:, **)
            c = @chrysalises.fetch(chrysalis_id, nil)
            return { success: false, reason: :not_found } unless c

            c.spin!
            { success: true, stage: c.stage }
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def enclose(chrysalis_id:, cocoon_id:, **)
            c      = @chrysalises.fetch(chrysalis_id, nil)
            cocoon = @cocoons.fetch(cocoon_id, nil)
            return { success: false, reason: :chrysalis_not_found } unless c
            return { success: false, reason: :cocoon_not_found }    unless cocoon

            c.spin! if c.stage == :larva
            c.cocoon! if c.stage == :spinning
            cocoon.shelter(chrysalis_id)
            @sheltered[chrysalis_id] = cocoon_id
            { success: true, stage: c.stage, cocoon_id: cocoon_id }
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def incubate(chrysalis_id:, **)
            c = @chrysalises.fetch(chrysalis_id, nil)
            return { success: false, reason: :not_found } unless c
            return { success: false, reason: :already_butterfly } if c.butterfly?

            rate = Helpers::Constants::TRANSFORMATION_RATE
            if (cid = @sheltered[chrysalis_id])
              cocoon = @cocoons[cid]
              rate  += cocoon.growth_modifier if cocoon
            end

            c.transform!(rate)
            { success: true, progress: c.transformation_progress, stage: c.stage }
          end

          def force_emerge(chrysalis_id:, **)
            c = @chrysalises.fetch(chrysalis_id, nil)
            return { success: false, reason: :not_found } unless c

            c.emerge!(force: true)
            { success: true, stage: c.stage, beauty: c.beauty, premature: c.premature? }
          end

          def natural_emerge(chrysalis_id:, **)
            c = @chrysalises.fetch(chrysalis_id, nil)
            return { success: false, reason: :not_found } unless c

            result = c.emerge!
            return { success: false, reason: :not_ready, progress: c.transformation_progress } unless result

            { success: true, stage: c.stage, beauty: c.beauty, premature: c.premature? }
          end

          def disturb_cocoon(cocoon_id:, force:, **)
            cocoon = @cocoons.fetch(cocoon_id, nil)
            return { success: false, reason: :not_found } unless cocoon

            disturbed = []
            cocoon.chrysalis_ids.each do |cid|
              c = @chrysalises[cid]
              next unless c

              c.disturb!(force.to_f)
              disturbed << { chrysalis_id: cid, protection: c.protection, stage: c.stage }
            end
            { success: true, disturbed: disturbed, force: force }
          end

          def incubate_all!(**)
            results = []
            @chrysalises.each_value do |c|
              next unless %i[cocooned transforming].include?(c.stage)

              rate = Helpers::Constants::TRANSFORMATION_RATE
              if (cid = @sheltered[c.id])
                cocoon = @cocoons[cid]
                rate  += cocoon.growth_modifier if cocoon
              end
              c.transform!(rate)
              results << { chrysalis_id: c.id, progress: c.transformation_progress, stage: c.stage }
            end
            { success: true, incubated: results.size, results: results }
          end

          def butterflies
            @chrysalises.values.select(&:butterfly?)
          end

          def metamorphosis_report(**)
            all = @chrysalises.values
            butterfly_list = all.select(&:butterfly?)
            {
              total_chrysalises:  all.size,
              total_cocoons:      @cocoons.size,
              butterflies_count:  butterfly_list.size,
              premature_count:    butterfly_list.count(&:premature?),
              avg_beauty:         avg_beauty(butterfly_list),
              avg_progress:       avg_progress(all),
              cocooned_count:     all.count(&:cocooned?),
              transforming_count: all.count(&:transforming?)
            }
          end

          private

          def avg_beauty(list)
            return 0.0 if list.empty?

            (list.sum(&:beauty) / list.size).round(10)
          end

          def avg_progress(list)
            return 0.0 if list.empty?

            (list.sum(&:transformation_progress) / list.size).round(10)
          end
        end
      end
    end
  end
end
