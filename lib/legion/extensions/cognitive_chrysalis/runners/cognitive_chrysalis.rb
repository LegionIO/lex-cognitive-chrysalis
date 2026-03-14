# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      module Runners
        module CognitiveChrysalis
          extend self

          begin
            include Legion::Extensions::Helpers::Lex # rubocop:disable Layout/EmptyLinesAfterModuleInclusion
          rescue StandardError
            nil
          end

          def create_chrysalis(chrysalis_type: :silk, content: '', engine: nil, **)
            engine ||= default_engine
            type = chrysalis_type.to_sym
            unless Helpers::Constants::CHRYSALIS_TYPES.include?(type)
              return { success: false, reason: :invalid_type, valid_types: Helpers::Constants::CHRYSALIS_TYPES }
            end

            Legion::Logging.debug "[cognitive_chrysalis] creating chrysalis type=#{type}"
            engine.create_chrysalis(chrysalis_type: type, content: content)
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def create_cocoon(environment: 'default', temperature: 0.5, humidity: 0.5, engine: nil, **)
            engine ||= default_engine
            Legion::Logging.debug "[cognitive_chrysalis] creating cocoon environment=#{environment}"
            engine.create_cocoon(environment: environment, temperature: temperature, humidity: humidity)
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def spin(chrysalis_id:, engine: nil, **)
            return { success: false, reason: :missing_chrysalis_id } if chrysalis_id.nil?

            engine ||= default_engine
            Legion::Logging.debug "[cognitive_chrysalis] spinning chrysalis=#{chrysalis_id}"
            engine.spin(chrysalis_id: chrysalis_id)
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def enclose(chrysalis_id:, cocoon_id:, engine: nil, **)
            return { success: false, reason: :missing_chrysalis_id } if chrysalis_id.nil?
            return { success: false, reason: :missing_cocoon_id }    if cocoon_id.nil?

            engine ||= default_engine
            Legion::Logging.debug "[cognitive_chrysalis] enclosing chrysalis=#{chrysalis_id} in cocoon=#{cocoon_id}"
            engine.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id)
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def incubate(chrysalis_id:, engine: nil, **)
            return { success: false, reason: :missing_chrysalis_id } if chrysalis_id.nil?

            engine ||= default_engine
            Legion::Logging.debug "[cognitive_chrysalis] incubating chrysalis=#{chrysalis_id}"
            engine.incubate(chrysalis_id: chrysalis_id)
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def incubate_all(engine: nil, **)
            engine ||= default_engine
            Legion::Logging.debug '[cognitive_chrysalis] incubating all eligible chrysalises'
            engine.incubate_all!
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def emerge(chrysalis_id:, force: false, engine: nil, **)
            return { success: false, reason: :missing_chrysalis_id } if chrysalis_id.nil?

            engine ||= default_engine
            Legion::Logging.debug "[cognitive_chrysalis] emerging chrysalis=#{chrysalis_id} force=#{force}"
            if force
              engine.force_emerge(chrysalis_id: chrysalis_id)
            else
              engine.natural_emerge(chrysalis_id: chrysalis_id)
            end
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def disturb(cocoon_id:, force: 0.1, engine: nil, **)
            return { success: false, reason: :missing_cocoon_id } if cocoon_id.nil?

            engine ||= default_engine
            Legion::Logging.debug "[cognitive_chrysalis] disturbing cocoon=#{cocoon_id} force=#{force}"
            engine.disturb_cocoon(cocoon_id: cocoon_id, force: force)
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def list_chrysalises(engine: nil, **)
            engine ||= default_engine
            all = engine.instance_variable_get(:@chrysalises) || {}
            { success: true, chrysalises: all.values.map(&:to_h), count: all.size }
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          def metamorphosis_status(engine: nil, **)
            engine ||= default_engine
            report = engine.metamorphosis_report
            { success: true }.merge(report)
          rescue ArgumentError => e
            { success: false, reason: e.message }
          end

          private

          def default_engine
            @default_engine ||= Helpers::MetamorphosisEngine.new
          end
        end
      end
    end
  end
end
