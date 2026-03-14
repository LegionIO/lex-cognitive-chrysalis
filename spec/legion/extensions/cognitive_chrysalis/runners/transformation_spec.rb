# frozen_string_literal: true

require 'legion/extensions/cognitive_chrysalis/client'

RSpec.describe Legion::Extensions::CognitiveChrysalis::Runners::Transformation do
  let(:engine) { Legion::Extensions::CognitiveChrysalis::Helpers::ChrysalisEngine.new }
  let(:client) { Legion::Extensions::CognitiveChrysalis::Client.new(engine: engine) }
  let(:phase_mod) { Legion::Extensions::CognitiveChrysalis::Helpers::TransformationPhase }

  def make_phase(name, duration_ticks)
    phase_mod.new_phase(name: name, duration_ticks: duration_ticks)
  end

  describe '#begin_transformation' do
    it 'returns success true with a cycle_id' do
      result = client.begin_transformation(trigger: 'test', domain: :cognitive)
      expect(result[:success]).to be true
      expect(result[:cycle_id]).not_to be_nil
    end

    it 'returns failure when cooldown active' do
      engine.instance_variable_set(:@cooldown_remaining, 3)
      result = client.begin_transformation(trigger: 'test', domain: :cognitive)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:cooldown_active)
    end
  end

  describe '#advance_cycle' do
    it 'advances an existing cycle' do
      started = client.begin_transformation(trigger: 'test', domain: :emotional,
                                            phases: [make_phase(:larval, 5)])
      result = client.advance_cycle(cycle_id: started[:cycle_id])
      expect(result[:success]).to be true
      expect(result[:progress]).to be > 0.0
    end

    it 'returns failure for unknown cycle' do
      result = client.advance_cycle(cycle_id: 'unknown')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#offline_capabilities' do
    it 'records offline capabilities' do
      started = client.begin_transformation(trigger: 'test', domain: :behavioral)
      result = client.offline_capabilities(cycle_id: started[:cycle_id], capabilities: ['focus'])
      expect(result[:success]).to be true
      expect(result[:offline]).to include('focus')
    end
  end

  describe '#restore_capabilities' do
    it 'restores previously offline capabilities' do
      started = client.begin_transformation(trigger: 'test', domain: :cognitive)
      client.offline_capabilities(cycle_id: started[:cycle_id], capabilities: ['reasoning'])
      result = client.restore_capabilities(cycle_id: started[:cycle_id])
      expect(result[:success]).to be true
      expect(result[:restored]).to include('reasoning')
    end
  end

  describe '#record_emergence' do
    it 'records an emergence event' do
      started = client.begin_transformation(trigger: 'test', domain: :creative)
      result = client.record_emergence(cycle_id: started[:cycle_id], insight: 'clarity')
      expect(result[:success]).to be true
      expect(result[:event_id]).not_to be_nil
    end
  end
end
