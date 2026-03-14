# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Helpers::ChrysalisEngine do
  subject(:engine) { described_class.new }

  let(:phase_mod) { Legion::Extensions::CognitiveChrysalis::Helpers::TransformationPhase }

  def make_phase(name, duration_ticks)
    phase_mod.new_phase(name: name, duration_ticks: duration_ticks)
  end

  describe '#begin_transformation' do
    it 'creates a new active cycle' do
      result = engine.begin_transformation(trigger: 'insight', domain: :cognitive)
      expect(result[:success]).to be true
      expect(result[:cycle_id]).not_to be_nil
      expect(engine.active_cycles.size).to eq(1)
    end

    it 'returns failure when cooldown is active' do
      engine.instance_variable_set(:@cooldown_remaining, 5)
      result = engine.begin_transformation(trigger: 'x', domain: :cognitive)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:cooldown_active)
      expect(result[:remaining]).to eq(5)
    end

    it 'returns failure when max cycles reached' do
      engine.instance_variable_set(:@completed_cycles, Array.new(50))
      result = engine.begin_transformation(trigger: 'x', domain: :cognitive)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:max_cycles_reached)
    end
  end

  describe '#advance_cycle' do
    it 'advances an active cycle' do
      started = engine.begin_transformation(trigger: 'test', domain: :emotional,
                                            phases: [make_phase(:larval, 5)])
      result = engine.advance_cycle(cycle_id: started[:cycle_id])
      expect(result[:success]).to be true
      expect(result[:status]).to eq(:active)
    end

    it 'returns failure for unknown cycle_id' do
      result = engine.advance_cycle(cycle_id: 'nonexistent-id')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end

    it 'moves completed cycle to completed_cycles' do
      started = engine.begin_transformation(trigger: 'test', domain: :cognitive,
                                            phases: [make_phase(:emergence, 1)])
      engine.advance_cycle(cycle_id: started[:cycle_id])
      expect(engine.active_cycles).to be_empty
      expect(engine.completed_cycles.size).to eq(1)
    end

    it 'sets cooldown after emergence' do
      started = engine.begin_transformation(trigger: 'test', domain: :cognitive,
                                            phases: [make_phase(:emergence, 1)])
      engine.advance_cycle(cycle_id: started[:cycle_id])
      expect(engine.cooldown_remaining).to eq(
        Legion::Extensions::CognitiveChrysalis::Helpers::Constants::COOLDOWN_CYCLES
      )
    end
  end

  describe '#offline_capabilities' do
    it 'adds capabilities to dissolution inventory' do
      started = engine.begin_transformation(trigger: 'test', domain: :behavioral)
      result = engine.offline_capabilities(cycle_id: started[:cycle_id],
                                           capabilities: %w[reasoning empathy])
      expect(result[:success]).to be true
      expect(result[:offline]).to include('reasoning', 'empathy')
    end

    it 'does not duplicate capabilities' do
      started = engine.begin_transformation(trigger: 'test', domain: :behavioral)
      engine.offline_capabilities(cycle_id: started[:cycle_id], capabilities: ['reasoning'])
      engine.offline_capabilities(cycle_id: started[:cycle_id], capabilities: ['reasoning'])
      expect(engine.dissolution_inventory[started[:cycle_id]].count('reasoning')).to eq(1)
    end

    it 'returns failure for unknown cycle' do
      result = engine.offline_capabilities(cycle_id: 'unknown', capabilities: ['x'])
      expect(result[:success]).to be false
    end
  end

  describe '#restore_capabilities' do
    it 'removes cycle from dissolution inventory' do
      started = engine.begin_transformation(trigger: 'test', domain: :cognitive)
      engine.offline_capabilities(cycle_id: started[:cycle_id], capabilities: ['logic'])
      result = engine.restore_capabilities(cycle_id: started[:cycle_id])
      expect(result[:success]).to be true
      expect(result[:restored]).to include('logic')
      expect(engine.dissolution_inventory[started[:cycle_id]]).to be_nil
    end
  end

  describe '#record_emergence' do
    it 'records an emergence event for an active cycle' do
      started = engine.begin_transformation(trigger: 'test', domain: :creative)
      result = engine.record_emergence(cycle_id: started[:cycle_id], insight: 'new perspective')
      expect(result[:success]).to be true
      expect(result[:event_id]).not_to be_nil
      expect(engine.emergence_events.size).to eq(1)
    end

    it 'records an emergence event for a completed cycle' do
      started = engine.begin_transformation(trigger: 'test', domain: :cognitive,
                                            phases: [make_phase(:emergence, 1)])
      engine.advance_cycle(cycle_id: started[:cycle_id])
      result = engine.record_emergence(cycle_id: started[:cycle_id])
      expect(result[:success]).to be true
    end

    it 'returns failure for unknown cycle' do
      result = engine.record_emergence(cycle_id: 'unknown')
      expect(result[:success]).to be false
    end
  end

  describe '#transformation_history' do
    it 'returns empty array initially' do
      expect(engine.transformation_history).to eq([])
    end

    it 'includes completed cycles' do
      started = engine.begin_transformation(trigger: 'test', domain: :moral,
                                            phases: [make_phase(:emergence, 1)])
      engine.advance_cycle(cycle_id: started[:cycle_id])
      history = engine.transformation_history
      expect(history.size).to eq(1)
      expect(history.first[:domain]).to eq(:moral)
      expect(history.first[:status]).to eq(:emerged)
    end
  end

  describe '#most_transformed_domains' do
    it 'returns empty hash when no transformations' do
      expect(engine.most_transformed_domains).to eq({})
    end

    it 'counts transformed domains' do
      2.times do
        started = engine.begin_transformation(trigger: 'test', domain: :cognitive,
                                              phases: [make_phase(:emergence, 1)])
        cycle_id = started[:cycle_id]
        engine.instance_variable_get(:@active_cycles)[cycle_id][:emergence_score] = 0.95
        engine.advance_cycle(cycle_id: cycle_id)
      end
      domains = engine.most_transformed_domains
      expect(domains[:cognitive]).to eq(2)
    end
  end

  describe '#metamorphic_readiness' do
    it 'returns non-zero when idle with no history' do
      expect(engine.metamorphic_readiness).to eq(0.5)
    end

    it 'returns 0.0 when cooldown is active' do
      engine.instance_variable_set(:@cooldown_remaining, 3)
      expect(engine.metamorphic_readiness).to eq(0.0)
    end

    it 'returns 0.0 when active cycles exist' do
      engine.begin_transformation(trigger: 'test', domain: :cognitive)
      expect(engine.metamorphic_readiness).to eq(0.0)
    end
  end

  describe '#chrysalis_report' do
    it 'returns a summary hash' do
      report_result = engine.chrysalis_report
      expect(report_result).to have_key(:active_cycles)
      expect(report_result).to have_key(:completed_cycles)
      expect(report_result).to have_key(:emergence_events)
      expect(report_result).to have_key(:cooldown_remaining)
      expect(report_result).to have_key(:readiness)
      expect(report_result).to have_key(:readiness_label)
      expect(report_result).to have_key(:dissolved_domains)
    end

    it 'reports zero counts initially' do
      report_result = engine.chrysalis_report
      expect(report_result[:active_cycles]).to eq(0)
      expect(report_result[:completed_cycles]).to eq(0)
    end
  end

  describe '#tick_cooldown' do
    it 'decrements cooldown_remaining' do
      engine.instance_variable_set(:@cooldown_remaining, 5)
      engine.tick_cooldown
      expect(engine.cooldown_remaining).to eq(4)
    end

    it 'does not decrement below zero' do
      engine.tick_cooldown
      expect(engine.cooldown_remaining).to eq(0)
    end
  end
end
