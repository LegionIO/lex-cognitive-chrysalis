# frozen_string_literal: true

# Tests focused on Cocoon environment modifiers and their effect on transformation
RSpec.describe 'Cocoon environment effects' do
  let(:engine) { Legion::Extensions::CognitiveChrysalis::Helpers::MetamorphosisEngine.new }

  describe 'ideal cocoon' do
    let(:ideal_cocoon) do
      Legion::Extensions::CognitiveChrysalis::Helpers::Cocoon.new(
        environment: 'greenhouse',
        temperature: 0.55,
        humidity:    0.55
      )
    end

    it 'reports ideal? true' do
      expect(ideal_cocoon.ideal?).to be true
    end

    it 'has growth_modifier of 0.1' do
      expect(ideal_cocoon.growth_modifier).to eq(0.1)
    end

    it 'accelerates transformation compared to bare incubation' do
      base_rate = Legion::Extensions::CognitiveChrysalis::Helpers::Constants::TRANSFORMATION_RATE
      rate_with_cocoon = base_rate + ideal_cocoon.growth_modifier
      expect(rate_with_cocoon).to be > base_rate
    end
  end

  describe 'hostile cocoon' do
    let(:hostile_cocoon) do
      Legion::Extensions::CognitiveChrysalis::Helpers::Cocoon.new(
        environment: 'furnace',
        temperature: 0.95,
        humidity:    0.5
      )
    end

    it 'reports hostile? true' do
      expect(hostile_cocoon.hostile?).to be true
    end

    it 'has negative growth_modifier' do
      expect(hostile_cocoon.growth_modifier).to be < 0
    end

    it 'slows transformation below base rate' do
      base_rate = Legion::Extensions::CognitiveChrysalis::Helpers::Constants::TRANSFORMATION_RATE
      rate_with_cocoon = base_rate + hostile_cocoon.growth_modifier
      expect(rate_with_cocoon).to be < base_rate
    end
  end

  describe 'neutral cocoon' do
    let(:neutral_cocoon) do
      Legion::Extensions::CognitiveChrysalis::Helpers::Cocoon.new(
        environment: 'plain',
        temperature: 0.2,
        humidity:    0.5
      )
    end

    it 'has growth_modifier of 0.0' do
      expect(neutral_cocoon.growth_modifier).to eq(0.0)
    end

    it 'does not accelerate or slow transformation' do
      base_rate = Legion::Extensions::CognitiveChrysalis::Helpers::Constants::TRANSFORMATION_RATE
      expect(base_rate + neutral_cocoon.growth_modifier).to eq(base_rate)
    end
  end

  describe 'temperature and humidity adjustments' do
    let(:cocoon) { Legion::Extensions::CognitiveChrysalis::Helpers::Cocoon.new(environment: 'test') }

    it 'moisten and dry are inverse operations (roughly)' do
      original = cocoon.humidity
      cocoon.moisten!
      cocoon.dry!
      expect(cocoon.humidity).to be_within(0.001).of(original)
    end

    it 'warm and cool are inverse operations (roughly)' do
      original = cocoon.temperature
      cocoon.warm!
      cocoon.cool!
      expect(cocoon.temperature).to be_within(0.001).of(original)
    end

    it 'sheltering and exposing a chrysalis affects chrysalis_ids' do
      cocoon.shelter('c-1')
      expect(cocoon.chrysalis_ids).to include('c-1')
      cocoon.expose('c-1')
      expect(cocoon.chrysalis_ids).not_to include('c-1')
    end
  end
end
