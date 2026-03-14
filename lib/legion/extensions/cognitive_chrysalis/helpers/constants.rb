# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      module Helpers
        module Constants
          LIFE_STAGES = %i[larva spinning cocooned transforming emerging butterfly].freeze
          CHRYSALIS_TYPES = %i[silk paper bark leaf underground].freeze

          MAX_CHRYSALISES    = 200
          MAX_BUTTERFLIES    = 500
          TRANSFORMATION_RATE = 0.08
          PROTECTION_DECAY = 0.03
          EMERGENCE_THRESHOLD = 0.9
          PREMATURE_PENALTY = 0.4

          STAGE_LABELS = {
            (0.0...0.20)  => :larva,
            (0.20...0.40) => :spinning,
            (0.40...0.60) => :cocooned,
            (0.60...0.80) => :transforming,
            (0.80...0.90) => :emerging,
            (0.90..1.0)   => :butterfly
          }.freeze

          BEAUTY_LABELS = {
            (0.0...0.20)  => :dull,
            (0.20...0.40) => :plain,
            (0.40...0.65) => :striking,
            (0.65...0.85) => :beautiful,
            (0.85..1.0)   => :magnificent
          }.freeze

          def self.label_for(table, value)
            table.each do |range, label|
              return label if range.cover?(value)
            end
            table.values.last
          end
        end
      end
    end
  end
end
