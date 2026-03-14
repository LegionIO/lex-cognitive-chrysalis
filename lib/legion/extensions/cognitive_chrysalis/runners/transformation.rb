# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      module Runners
        module Transformation
          def begin_transformation(trigger:, domain:, phases: [], engine: nil, **)
            engine ||= default_engine
            result = engine.begin_transformation(trigger: trigger, domain: domain, phases: phases)
            Legion::Logging.debug "[chrysalis] begin_transformation domain=#{domain} success=#{result[:success]}"
            result
          end

          def advance_cycle(cycle_id:, engine: nil, **)
            engine ||= default_engine
            result = engine.advance_cycle(cycle_id: cycle_id)
            Legion::Logging.debug "[chrysalis] advance_cycle cycle=#{cycle_id[0..7]} success=#{result[:success]}"
            result
          end

          def offline_capabilities(cycle_id:, capabilities: [], engine: nil, **)
            engine ||= default_engine
            result = engine.offline_capabilities(cycle_id: cycle_id, capabilities: capabilities)
            Legion::Logging.debug "[chrysalis] offline_capabilities cycle=#{cycle_id[0..7]} count=#{capabilities.size}"
            result
          end

          def restore_capabilities(cycle_id:, engine: nil, **)
            engine ||= default_engine
            result = engine.restore_capabilities(cycle_id: cycle_id)
            Legion::Logging.debug "[chrysalis] restore_capabilities cycle=#{cycle_id[0..7]}"
            result
          end

          def record_emergence(cycle_id:, insight: nil, engine: nil, **)
            engine ||= default_engine
            result = engine.record_emergence(cycle_id: cycle_id, insight: insight)
            Legion::Logging.debug "[chrysalis] record_emergence cycle=#{cycle_id[0..7]}"
            result
          end

          private

          def default_engine
            @default_engine ||= Helpers::ChrysalisEngine.new
          end

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)
        end
      end
    end
  end
end
