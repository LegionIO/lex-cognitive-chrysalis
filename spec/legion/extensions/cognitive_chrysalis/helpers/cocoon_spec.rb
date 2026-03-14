# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Helpers::Cocoon do
  subject(:cocoon) { described_class.new(environment: 'forest_floor') }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(cocoon.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets environment' do
      expect(cocoon.environment).to eq('forest_floor')
    end

    it 'defaults temperature to 0.5' do
      expect(cocoon.temperature).to eq(0.5)
    end

    it 'defaults humidity to 0.5' do
      expect(cocoon.humidity).to eq(0.5)
    end

    it 'starts with empty chrysalis_ids' do
      expect(cocoon.chrysalis_ids).to eq([])
    end

    it 'records created_at as a Time' do
      expect(cocoon.created_at).to be_a(Time)
    end

    it 'accepts custom temperature and humidity' do
      c = described_class.new(environment: 'sunny', temperature: 0.7, humidity: 0.3)
      expect(c.temperature).to eq(0.7)
      expect(c.humidity).to eq(0.3)
    end
  end

  describe '#shelter' do
    it 'adds a chrysalis_id to the list' do
      cocoon.shelter('abc-123')
      expect(cocoon.chrysalis_ids).to include('abc-123')
    end

    it 'returns true' do
      expect(cocoon.shelter('abc-123')).to be true
    end

    it 'does not duplicate existing ids' do
      cocoon.shelter('abc-123')
      cocoon.shelter('abc-123')
      expect(cocoon.chrysalis_ids.count('abc-123')).to eq(1)
    end
  end

  describe '#expose' do
    before { cocoon.shelter('abc-123') }

    it 'removes a chrysalis_id from the list' do
      cocoon.expose('abc-123')
      expect(cocoon.chrysalis_ids).not_to include('abc-123')
    end

    it 'returns true' do
      expect(cocoon.expose('abc-123')).to be true
    end

    it 'is idempotent for non-existent ids' do
      expect { cocoon.expose('non-existent') }.not_to raise_error
    end
  end

  describe '#warm!' do
    it 'increases temperature by TEMP_ADJUST' do
      before_temp = cocoon.temperature
      cocoon.warm!
      expect(cocoon.temperature).to be > before_temp
    end

    it 'clamps temperature at 1.0' do
      25.times { cocoon.warm! }
      expect(cocoon.temperature).to eq(1.0)
    end
  end

  describe '#cool!' do
    it 'decreases temperature by TEMP_ADJUST' do
      before_temp = cocoon.temperature
      cocoon.cool!
      expect(cocoon.temperature).to be < before_temp
    end

    it 'clamps temperature at 0.0' do
      25.times { cocoon.cool! }
      expect(cocoon.temperature).to eq(0.0)
    end
  end

  describe '#moisten!' do
    it 'increases humidity by HUMID_ADJUST' do
      before_humid = cocoon.humidity
      cocoon.moisten!
      expect(cocoon.humidity).to be > before_humid
    end

    it 'clamps humidity at 1.0' do
      25.times { cocoon.moisten! }
      expect(cocoon.humidity).to eq(1.0)
    end
  end

  describe '#dry!' do
    it 'decreases humidity by HUMID_ADJUST' do
      before_humid = cocoon.humidity
      cocoon.dry!
      expect(cocoon.humidity).to be < before_humid
    end

    it 'clamps humidity at 0.0' do
      25.times { cocoon.dry! }
      expect(cocoon.humidity).to eq(0.0)
    end
  end

  describe '#ideal?' do
    it 'returns true when temperature and humidity are both in 0.4-0.7 range' do
      ideal = described_class.new(environment: 'ideal', temperature: 0.55, humidity: 0.55)
      expect(ideal.ideal?).to be true
    end

    it 'returns false when temperature is out of ideal range' do
      c = described_class.new(environment: 'hot', temperature: 0.8, humidity: 0.5)
      expect(c.ideal?).to be false
    end

    it 'returns false when humidity is out of ideal range' do
      c = described_class.new(environment: 'dry', temperature: 0.5, humidity: 0.2)
      expect(c.ideal?).to be false
    end
  end

  describe '#hostile?' do
    it 'returns true when temperature > 0.9' do
      c = described_class.new(environment: 'furnace', temperature: 0.95, humidity: 0.5)
      expect(c.hostile?).to be true
    end

    it 'returns true when humidity < 0.1' do
      c = described_class.new(environment: 'desert', temperature: 0.5, humidity: 0.05)
      expect(c.hostile?).to be true
    end

    it 'returns false for normal conditions' do
      expect(cocoon.hostile?).to be false
    end
  end

  describe '#growth_modifier' do
    it 'returns 0.1 for ideal conditions' do
      ideal = described_class.new(environment: 'ideal', temperature: 0.55, humidity: 0.55)
      expect(ideal.growth_modifier).to eq(0.1)
    end

    it 'returns -0.05 for hostile conditions' do
      hostile = described_class.new(environment: 'hostile', temperature: 0.95, humidity: 0.5)
      expect(hostile.growth_modifier).to eq(-0.05)
    end

    it 'returns 0.0 for neutral conditions' do
      neutral = described_class.new(environment: 'neutral', temperature: 0.2, humidity: 0.5)
      expect(neutral.growth_modifier).to eq(0.0)
    end
  end

  describe '#to_h' do
    it 'returns a Hash' do
      expect(cocoon.to_h).to be_a(Hash)
    end

    it 'includes all key fields' do
      h = cocoon.to_h
      expect(h[:id]).to eq(cocoon.id)
      expect(h[:environment]).to eq('forest_floor')
      expect(h[:temperature]).to eq(0.5)
      expect(h[:humidity]).to eq(0.5)
      expect(h[:chrysalis_ids]).to eq([])
    end

    it 'includes ideal and hostile booleans' do
      h = cocoon.to_h
      expect(h).to have_key(:ideal)
      expect(h).to have_key(:hostile)
    end

    it 'includes growth_modifier' do
      h = cocoon.to_h
      expect(h).to have_key(:growth_modifier)
    end

    it 'returns a dup of chrysalis_ids (not the original array)' do
      cocoon.shelter('id-1')
      h = cocoon.to_h
      h[:chrysalis_ids] << 'injected'
      expect(cocoon.chrysalis_ids).not_to include('injected')
    end
  end
end
