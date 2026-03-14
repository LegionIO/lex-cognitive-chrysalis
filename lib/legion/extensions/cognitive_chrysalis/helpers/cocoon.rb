# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveChrysalis
      module Helpers
        class Cocoon
          attr_reader :id, :environment, :temperature, :humidity, :chrysalis_ids, :created_at

          TEMP_ADJUST = 0.05
          HUMID_ADJUST = 0.05

          def initialize(environment:, temperature: 0.5, humidity: 0.5, **)
            @id            = SecureRandom.uuid
            @environment   = environment.to_s
            @temperature   = temperature.to_f.clamp(0.0, 1.0)
            @humidity      = humidity.to_f.clamp(0.0, 1.0)
            @chrysalis_ids = []
            @created_at    = Time.now.utc
          end

          def shelter(chrysalis_id)
            @chrysalis_ids << chrysalis_id unless @chrysalis_ids.include?(chrysalis_id)
            true
          end

          def expose(chrysalis_id)
            @chrysalis_ids.delete(chrysalis_id)
            true
          end

          def warm!
            @temperature = (@temperature + TEMP_ADJUST).clamp(0.0, 1.0).round(10)
          end

          def cool!
            @temperature = (@temperature - TEMP_ADJUST).clamp(0.0, 1.0).round(10)
          end

          def moisten!
            @humidity = (@humidity + HUMID_ADJUST).clamp(0.0, 1.0).round(10)
          end

          def dry!
            @humidity = (@humidity - HUMID_ADJUST).clamp(0.0, 1.0).round(10)
          end

          def ideal?
            @temperature.between?(0.4, 0.7) && @humidity.between?(0.4, 0.7)
          end

          def hostile?
            @temperature > 0.9 || @humidity < 0.1
          end

          def growth_modifier
            if ideal?
              0.1
            elsif hostile?
              -0.05
            else
              0.0
            end
          end

          def to_h
            {
              id:              @id,
              environment:     @environment,
              temperature:     @temperature,
              humidity:        @humidity,
              chrysalis_ids:   @chrysalis_ids.dup,
              ideal:           ideal?,
              hostile:         hostile?,
              growth_modifier: growth_modifier,
              created_at:      @created_at
            }
          end
        end
      end
    end
  end
end
