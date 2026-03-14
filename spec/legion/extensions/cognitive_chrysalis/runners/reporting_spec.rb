# frozen_string_literal: true

require 'legion/extensions/cognitive_chrysalis/client'

RSpec.describe Legion::Extensions::CognitiveChrysalis::Runners::Reporting do
  let(:engine) { Legion::Extensions::CognitiveChrysalis::Helpers::ChrysalisEngine.new }
  let(:client) { Legion::Extensions::CognitiveChrysalis::Client.new(engine: engine) }
  let(:phase_mod) { Legion::Extensions::CognitiveChrysalis::Helpers::TransformationPhase }

  def make_phase(name, duration_ticks)
    phase_mod.new_phase(name: name, duration_ticks: duration_ticks)
  end

  describe '#transformation_history' do
    it 'returns success with empty history initially' do
      result = client.transformation_history
      expect(result[:success]).to be true
      expect(result[:count]).to eq(0)
      expect(result[:history]).to eq([])
    end

    it 'includes completed transformations' do
      started = client.begin_transformation(trigger: 'test', domain: :analytical,
                                            phases: [make_phase(:emergence, 1)])
      client.advance_cycle(cycle_id: started[:cycle_id])
      result = client.transformation_history
      expect(result[:count]).to eq(1)
      expect(result[:history].first[:domain]).to eq(:analytical)
    end
  end

  describe '#most_transformed_domains' do
    it 'returns success with empty domains initially' do
      result = client.most_transformed_domains
      expect(result[:success]).to be true
      expect(result[:domains]).to eq({})
    end
  end

  describe '#metamorphic_readiness' do
    it 'returns success with readiness score' do
      result = client.metamorphic_readiness
      expect(result[:success]).to be true
      expect(result[:readiness]).to be_a(Float)
      expect(result[:label]).not_to be_nil
    end

    it 'returns :dormant when cooldown is active' do
      engine.instance_variable_set(:@cooldown_remaining, 5)
      result = client.metamorphic_readiness
      expect(result[:readiness]).to eq(0.0)
      expect(result[:label]).to eq(:dormant)
    end
  end

  describe '#chrysalis_report' do
    it 'returns success with full report' do
      result = client.chrysalis_report
      expect(result[:success]).to be true
      report = result[:report]
      expect(report[:active_cycles]).to eq(0)
      expect(report[:completed_cycles]).to eq(0)
      expect(report[:readiness_label]).not_to be_nil
    end
  end

  describe '#tick_cooldown' do
    it 'decrements cooldown and returns success' do
      engine.instance_variable_set(:@cooldown_remaining, 3)
      result = client.tick_cooldown
      expect(result[:success]).to be true
      expect(result[:cooldown_remaining]).to eq(2)
    end

    it 'handles zero cooldown gracefully' do
      result = client.tick_cooldown
      expect(result[:success]).to be true
      expect(result[:cooldown_remaining]).to eq(0)
    end
  end
end
