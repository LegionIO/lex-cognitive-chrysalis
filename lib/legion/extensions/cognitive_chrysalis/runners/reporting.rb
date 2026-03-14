# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveChrysalis
      module Runners
        module Reporting
          def transformation_history(engine: nil, **)
            engine ||= default_engine
            history = engine.transformation_history
            Legion::Logging.debug "[chrysalis] transformation_history count=#{history.size}"
            { success: true, count: history.size, history: history }
          end

          def most_transformed_domains(engine: nil, **)
            engine ||= default_engine
            domains = engine.most_transformed_domains
            Legion::Logging.debug "[chrysalis] most_transformed_domains count=#{domains.size}"
            { success: true, domains: domains }
          end

          def metamorphic_readiness(engine: nil, **)
            engine ||= default_engine
            readiness = engine.metamorphic_readiness
            label = Constants.label_for(Constants::READINESS_LABELS, readiness)
            Legion::Logging.debug "[chrysalis] metamorphic_readiness=#{readiness.round(3)} label=#{label}"
            { success: true, readiness: readiness, label: label }
          end

          def chrysalis_report(engine: nil, **)
            engine ||= default_engine
            report = engine.chrysalis_report
            Legion::Logging.debug "[chrysalis] chrysalis_report active=#{report[:active_cycles]} completed=#{report[:completed_cycles]}"
            { success: true, report: report }
          end

          def tick_cooldown(engine: nil, **)
            engine ||= default_engine
            engine.tick_cooldown
            Legion::Logging.debug "[chrysalis] tick_cooldown remaining=#{engine.cooldown_remaining}"
            { success: true, cooldown_remaining: engine.cooldown_remaining }
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
