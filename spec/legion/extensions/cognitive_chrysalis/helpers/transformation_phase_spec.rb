# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Helpers::TransformationPhase do
  let(:mod) { described_class }

  describe '.new_phase' do
    it 'creates a valid phase hash' do
      phase = mod.new_phase(name: :larval, duration_ticks: 10)
      expect(phase[:name]).to eq(:larval)
      expect(phase[:duration_ticks]).to eq(10)
      expect(phase[:intensity]).to eq(0.5)
      expect(phase[:domain]).to eq(:cognitive)
      expect(phase[:ticks_elapsed]).to eq(0)
      expect(phase[:started_at]).to be_nil
      expect(phase[:completed_at]).to be_nil
    end

    it 'accepts custom intensity and domain' do
      phase = mod.new_phase(name: :chrysalis, duration_ticks: 5, intensity: 0.8, domain: :emotional)
      expect(phase[:intensity]).to eq(0.8)
      expect(phase[:domain]).to eq(:emotional)
    end

    it 'clamps intensity to 0.0..1.0' do
      phase = mod.new_phase(name: :growth, duration_ticks: 3, intensity: 2.5)
      expect(phase[:intensity]).to eq(1.0)
    end

    it 'clamps duration_ticks minimum to 1' do
      phase = mod.new_phase(name: :emergence, duration_ticks: -5)
      expect(phase[:duration_ticks]).to eq(1)
    end

    it 'raises on invalid phase name' do
      expect { mod.new_phase(name: :invalid_phase, duration_ticks: 5) }.to raise_error(ArgumentError, /invalid phase name/)
    end

    it 'raises on invalid domain' do
      expect { mod.new_phase(name: :larval, duration_ticks: 5, domain: :unknown) }.to raise_error(ArgumentError, /invalid domain/)
    end

    it 'accepts description' do
      phase = mod.new_phase(name: :reformation, duration_ticks: 8, description: 'rebuilding')
      expect(phase[:description]).to eq('rebuilding')
    end
  end

  describe '.advance_phase' do
    it 'increments ticks_elapsed' do
      phase = mod.new_phase(name: :larval, duration_ticks: 5)
      advanced = mod.advance_phase(phase)
      expect(advanced[:ticks_elapsed]).to eq(1)
    end

    it 'sets started_at on first advance' do
      phase = mod.new_phase(name: :larval, duration_ticks: 5)
      advanced = mod.advance_phase(phase)
      expect(advanced[:started_at]).not_to be_nil
    end

    it 'sets completed_at when duration reached' do
      phase = mod.new_phase(name: :chrysalis, duration_ticks: 1)
      advanced = mod.advance_phase(phase)
      expect(advanced[:completed_at]).not_to be_nil
    end

    it 'does not advance a complete phase' do
      phase = mod.new_phase(name: :larval, duration_ticks: 1)
      completed = mod.advance_phase(phase)
      again = mod.advance_phase(completed)
      expect(again[:ticks_elapsed]).to eq(1)
    end

    it 'does not mutate the original phase' do
      phase = mod.new_phase(name: :larval, duration_ticks: 5)
      mod.advance_phase(phase)
      expect(phase[:ticks_elapsed]).to eq(0)
    end
  end

  describe '.complete?' do
    it 'returns false for a new phase' do
      phase = mod.new_phase(name: :larval, duration_ticks: 5)
      expect(mod.complete?(phase)).to be false
    end

    it 'returns true when ticks_elapsed >= duration_ticks' do
      phase = mod.new_phase(name: :larval, duration_ticks: 1)
      completed = mod.advance_phase(phase)
      expect(mod.complete?(completed)).to be true
    end
  end

  describe '.progress' do
    it 'returns 0.0 for new phase' do
      phase = mod.new_phase(name: :larval, duration_ticks: 10)
      expect(mod.progress(phase)).to eq(0.0)
    end

    it 'returns 0.5 at halfway' do
      phase = mod.new_phase(name: :larval, duration_ticks: 2)
      advanced = mod.advance_phase(phase)
      expect(mod.progress(advanced)).to eq(0.5)
    end

    it 'returns 1.0 when complete' do
      phase = mod.new_phase(name: :larval, duration_ticks: 1)
      completed = mod.advance_phase(phase)
      expect(mod.progress(completed)).to eq(1.0)
    end
  end

  describe '.intensity_label' do
    it 'returns :subtle for default intensity 0.0' do
      phase = mod.new_phase(name: :larval, duration_ticks: 1, intensity: 0.1)
      expect(mod.intensity_label(phase)).to eq(:subtle)
    end

    it 'returns :profound for high intensity' do
      phase = mod.new_phase(name: :larval, duration_ticks: 1, intensity: 0.9)
      expect(mod.intensity_label(phase)).to eq(:profound)
    end
  end
end
