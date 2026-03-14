# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      module Helpers
        module Constants
          MAX_CYCLES            = 50
          MAX_PHASES_PER_CYCLE  = 8
          DEFAULT_INTENSITY     = 0.5
          DISSOLUTION_RATE      = 0.12
          REFORMATION_RATE      = 0.08
          EMERGENCE_THRESHOLD   = 0.9
          COOLDOWN_CYCLES       = 10

          PHASE_NAMES = %i[larval growth dissolution chrysalis reformation emergence].freeze

          TRANSFORMATION_DOMAINS = %i[
            cognitive
            emotional
            behavioral
            relational
            creative
            analytical
            moral
            fundamental
          ].freeze

          INTENSITY_LABELS = {
            (0.0..0.25)  => :subtle,
            (0.25..0.50) => :moderate,
            (0.50..0.75) => :significant,
            (0.75..1.0)  => :profound
          }.freeze

          PROGRESS_LABELS = {
            (0.0..0.25)  => :beginning,
            (0.25..0.50) => :underway,
            (0.50..0.75) => :deepening,
            (0.75..1.0)  => :culminating
          }.freeze

          READINESS_LABELS = {
            (0.0..0.30)  => :dormant,
            (0.30..0.60) => :stirring,
            (0.60..0.85) => :receptive,
            (0.85..1.0)  => :ready
          }.freeze

          def self.label_for(labels_hash, value)
            labels_hash.each do |range, label|
              return label if range.cover?(value)
            end
            labels_hash.values.last
          end
        end
      end
    end
  end
end
