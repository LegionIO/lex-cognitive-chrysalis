# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Helpers::Constants do
  describe 'constants' do
    it 'defines MAX_CYCLES' do
      expect(described_class::MAX_CYCLES).to eq(50)
    end

    it 'defines MAX_PHASES_PER_CYCLE' do
      expect(described_class::MAX_PHASES_PER_CYCLE).to eq(8)
    end

    it 'defines DEFAULT_INTENSITY' do
      expect(described_class::DEFAULT_INTENSITY).to eq(0.5)
    end

    it 'defines DISSOLUTION_RATE' do
      expect(described_class::DISSOLUTION_RATE).to eq(0.12)
    end

    it 'defines REFORMATION_RATE' do
      expect(described_class::REFORMATION_RATE).to eq(0.08)
    end

    it 'defines EMERGENCE_THRESHOLD' do
      expect(described_class::EMERGENCE_THRESHOLD).to eq(0.9)
    end

    it 'defines COOLDOWN_CYCLES' do
      expect(described_class::COOLDOWN_CYCLES).to eq(10)
    end

    it 'defines 6 PHASE_NAMES' do
      expect(described_class::PHASE_NAMES.size).to eq(6)
      expect(described_class::PHASE_NAMES).to include(:larval, :growth, :dissolution, :chrysalis, :reformation, :emergence)
    end

    it 'defines 8 TRANSFORMATION_DOMAINS' do
      expect(described_class::TRANSFORMATION_DOMAINS.size).to eq(8)
      expect(described_class::TRANSFORMATION_DOMAINS).to include(:cognitive, :emotional, :behavioral, :fundamental)
    end
  end

  describe '.label_for' do
    it 'returns :subtle for low intensity' do
      expect(described_class.label_for(described_class::INTENSITY_LABELS, 0.1)).to eq(:subtle)
    end

    it 'returns :profound for high intensity' do
      expect(described_class.label_for(described_class::INTENSITY_LABELS, 0.9)).to eq(:profound)
    end

    it 'returns :moderate for mid-range' do
      expect(described_class.label_for(described_class::INTENSITY_LABELS, 0.35)).to eq(:moderate)
    end

    it 'returns :beginning for low progress' do
      expect(described_class.label_for(described_class::PROGRESS_LABELS, 0.1)).to eq(:beginning)
    end

    it 'returns :culminating for high progress' do
      expect(described_class.label_for(described_class::PROGRESS_LABELS, 0.9)).to eq(:culminating)
    end

    it 'returns :dormant for zero readiness' do
      expect(described_class.label_for(described_class::READINESS_LABELS, 0.0)).to eq(:dormant)
    end

    it 'returns :ready for high readiness' do
      expect(described_class.label_for(described_class::READINESS_LABELS, 0.95)).to eq(:ready)
    end
  end
end
