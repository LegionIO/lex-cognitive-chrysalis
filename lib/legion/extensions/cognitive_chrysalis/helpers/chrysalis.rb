# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveChrysalis
      module Helpers
        class Chrysalis
          attr_reader :id, :chrysalis_type, :content, :stage,
                      :transformation_progress, :protection, :beauty, :created_at

          def initialize(chrysalis_type:, content:, **)
            @id                     = SecureRandom.uuid
            @chrysalis_type         = chrysalis_type.to_sym
            @content                = content.to_s
            @stage                  = :larva
            @transformation_progress = 0.0
            @protection             = 0.8
            @beauty                 = 0.0
            @created_at             = Time.now.utc
            @premature              = false
          end

          def spin!
            raise ArgumentError, "must be :larva to spin, currently #{@stage}" unless @stage == :larva

            @stage = :spinning
            true
          end

          def cocoon!
            raise ArgumentError, "must be :spinning to cocoon, currently #{@stage}" unless @stage == :spinning

            @stage = :cocooned
            true
          end

          def transform!(rate = Helpers::Constants::TRANSFORMATION_RATE)
            return false if @stage == :butterfly

            @transformation_progress = (@transformation_progress + rate).clamp(0.0, 1.0).round(10)
            @beauty = (@transformation_progress * 0.9).clamp(0.0, 1.0).round(10)
            update_stage_from_progress!
            true
          end

          def emerge!(force: false)
            if @transformation_progress >= Helpers::Constants::EMERGENCE_THRESHOLD
              @stage  = :butterfly
              @beauty = 1.0
            elsif force
              @premature = true
              @stage     = :butterfly
              @beauty    = (@beauty - Helpers::Constants::PREMATURE_PENALTY).clamp(0.0, 1.0).round(10)
            else
              return false
            end
            true
          end

          def decay_protection!
            @protection = (@protection - Helpers::Constants::PROTECTION_DECAY).clamp(0.0, 1.0).round(10)
          end

          def disturb!(force)
            @protection = (@protection - force.to_f).clamp(0.0, 1.0).round(10)
            emerge!(force: true) if @protection <= 0 && %i[cocooned transforming].include?(@stage)
          end

          def butterfly?
            @stage == :butterfly
          end

          def cocooned?
            @stage == :cocooned
          end

          def transforming?
            @stage == :transforming
          end

          def premature?
            butterfly? && @beauty < 0.5
          end

          def stage_label
            Helpers::Constants.label_for(Helpers::Constants::STAGE_LABELS, @transformation_progress)
          end

          def beauty_label
            Helpers::Constants.label_for(Helpers::Constants::BEAUTY_LABELS, @beauty)
          end

          def to_h
            {
              id:                      @id,
              chrysalis_type:          @chrysalis_type,
              content:                 @content,
              stage:                   @stage,
              transformation_progress: @transformation_progress,
              protection:              @protection,
              beauty:                  @beauty,
              stage_label:             stage_label,
              beauty_label:            beauty_label,
              premature:               @premature,
              created_at:              @created_at
            }
          end

          private

          def update_stage_from_progress!
            progress_stage = if @transformation_progress >= 0.8
                               :emerging
                             elsif @transformation_progress >= 0.6
                               :transforming
                             elsif @transformation_progress >= 0.4
                               :cocooned
                             elsif @transformation_progress >= 0.2
                               :spinning
                             else
                               :larva
                             end
            current_rank  = Helpers::Constants::LIFE_STAGES.index(@stage) || 0
            progress_rank = Helpers::Constants::LIFE_STAGES.index(progress_stage) || 0
            @stage = Helpers::Constants::LIFE_STAGES[[current_rank, progress_rank].max]
          end
        end
      end
    end
  end
end
