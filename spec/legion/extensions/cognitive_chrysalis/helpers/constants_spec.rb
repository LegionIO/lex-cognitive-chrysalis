# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Helpers::Constants do
  subject(:constants) { described_class }

  describe 'LIFE_STAGES' do
    it 'contains the six metamorphic stages' do
      expect(constants::LIFE_STAGES).to eq(%i[larva spinning cocooned transforming emerging butterfly])
    end

    it 'is frozen' do
      expect(constants::LIFE_STAGES).to be_frozen
    end
  end

  describe 'CHRYSALIS_TYPES' do
    it 'contains the five chrysalis types' do
      expect(constants::CHRYSALIS_TYPES).to eq(%i[silk paper bark leaf underground])
    end

    it 'is frozen' do
      expect(constants::CHRYSALIS_TYPES).to be_frozen
    end
  end

  describe 'numeric constants' do
    it 'has MAX_CHRYSALISES = 200' do
      expect(constants::MAX_CHRYSALISES).to eq(200)
    end

    it 'has MAX_BUTTERFLIES = 500' do
      expect(constants::MAX_BUTTERFLIES).to eq(500)
    end

    it 'has TRANSFORMATION_RATE = 0.08' do
      expect(constants::TRANSFORMATION_RATE).to eq(0.08)
    end

    it 'has PROTECTION_DECAY = 0.03' do
      expect(constants::PROTECTION_DECAY).to eq(0.03)
    end

    it 'has EMERGENCE_THRESHOLD = 0.9' do
      expect(constants::EMERGENCE_THRESHOLD).to eq(0.9)
    end

    it 'has PREMATURE_PENALTY = 0.4' do
      expect(constants::PREMATURE_PENALTY).to eq(0.4)
    end
  end

  describe 'STAGE_LABELS' do
    it 'is a hash' do
      expect(constants::STAGE_LABELS).to be_a(Hash)
    end

    it 'is frozen' do
      expect(constants::STAGE_LABELS).to be_frozen
    end
  end

  describe 'BEAUTY_LABELS' do
    it 'is a hash' do
      expect(constants::BEAUTY_LABELS).to be_a(Hash)
    end

    it 'is frozen' do
      expect(constants::BEAUTY_LABELS).to be_frozen
    end
  end

  describe '.label_for' do
    it 'returns :larva for progress 0.0' do
      expect(constants.label_for(constants::STAGE_LABELS, 0.0)).to eq(:larva)
    end

    it 'returns :butterfly for progress 0.95' do
      expect(constants.label_for(constants::STAGE_LABELS, 0.95)).to eq(:butterfly)
    end

    it 'returns :transforming for progress 0.7' do
      expect(constants.label_for(constants::STAGE_LABELS, 0.7)).to eq(:transforming)
    end

    it 'returns :dull for beauty 0.0' do
      expect(constants.label_for(constants::BEAUTY_LABELS, 0.0)).to eq(:dull)
    end

    it 'returns :magnificent for beauty 0.95' do
      expect(constants.label_for(constants::BEAUTY_LABELS, 0.95)).to eq(:magnificent)
    end

    it 'returns :beautiful for beauty 0.75' do
      expect(constants.label_for(constants::BEAUTY_LABELS, 0.75)).to eq(:beautiful)
    end

    it 'returns :striking for beauty 0.5' do
      expect(constants.label_for(constants::BEAUTY_LABELS, 0.5)).to eq(:striking)
    end

    it 'returns :plain for beauty 0.25' do
      expect(constants.label_for(constants::BEAUTY_LABELS, 0.25)).to eq(:plain)
    end

    it 'returns the last label when value exceeds all ranges' do
      expect(constants.label_for(constants::STAGE_LABELS, 1.1)).to eq(:butterfly)
    end
  end
end
