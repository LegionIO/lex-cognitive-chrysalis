# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Helpers::MetamorphosisEngine do
  subject(:engine) { described_class.new }

  let(:chrysalis_id) { engine.create_chrysalis(chrysalis_type: :silk, content: 'raw idea')[:chrysalis][:id] }
  let(:cocoon_id)    { engine.create_cocoon(environment: 'garden')[:cocoon][:id] }

  describe '#create_chrysalis' do
    it 'returns success: true' do
      result = engine.create_chrysalis(chrysalis_type: :silk, content: 'test')
      expect(result[:success]).to be true
    end

    it 'returns a chrysalis hash' do
      result = engine.create_chrysalis(chrysalis_type: :bark, content: 'test')
      expect(result[:chrysalis]).to be_a(Hash)
      expect(result[:chrysalis][:chrysalis_type]).to eq(:bark)
    end

    it 'returns success: false when at capacity' do
      stub_const('Legion::Extensions::CognitiveChrysalis::Helpers::Constants::MAX_CHRYSALISES', 1)
      engine.create_chrysalis(chrysalis_type: :silk, content: 'first')
      result = engine.create_chrysalis(chrysalis_type: :paper, content: 'second')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:capacity_exceeded)
    end
  end

  describe '#create_cocoon' do
    it 'returns success: true' do
      result = engine.create_cocoon(environment: 'meadow')
      expect(result[:success]).to be true
    end

    it 'includes cocoon hash with environment' do
      result = engine.create_cocoon(environment: 'meadow')
      expect(result[:cocoon][:environment]).to eq('meadow')
    end
  end

  describe '#spin' do
    it 'transitions the chrysalis to :spinning' do
      result = engine.spin(chrysalis_id: chrysalis_id)
      expect(result[:success]).to be true
      expect(result[:stage]).to eq(:spinning)
    end

    it 'returns failure for unknown chrysalis_id' do
      result = engine.spin(chrysalis_id: 'bad-id')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end

    it 'returns failure when already spun' do
      engine.spin(chrysalis_id: chrysalis_id)
      result = engine.spin(chrysalis_id: chrysalis_id)
      expect(result[:success]).to be false
    end
  end

  describe '#enclose' do
    it 'spins, cocoons, and shelters the chrysalis' do
      result = engine.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id)
      expect(result[:success]).to be true
      expect(result[:stage]).to eq(:cocooned)
    end

    it 'returns failure for unknown chrysalis' do
      result = engine.enclose(chrysalis_id: 'bad-id', cocoon_id: cocoon_id)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:chrysalis_not_found)
    end

    it 'returns failure for unknown cocoon' do
      result = engine.enclose(chrysalis_id: chrysalis_id, cocoon_id: 'bad-cocoon')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:cocoon_not_found)
    end
  end

  describe '#incubate' do
    before { engine.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id) }

    it 'increases transformation_progress' do
      result = engine.incubate(chrysalis_id: chrysalis_id)
      expect(result[:success]).to be true
      expect(result[:progress]).to be > 0.0
    end

    it 'returns failure for unknown chrysalis' do
      result = engine.incubate(chrysalis_id: 'bad-id')
      expect(result[:success]).to be false
    end

    it 'returns failure for an already-butterfly chrysalis' do
      12.times { engine.incubate(chrysalis_id: chrysalis_id) }
      engine.force_emerge(chrysalis_id: chrysalis_id)
      result = engine.incubate(chrysalis_id: chrysalis_id)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:already_butterfly)
    end

    it 'applies cocoon growth_modifier for ideal conditions' do
      ideal_cocoon = engine.create_cocoon(environment: 'ideal')[:cocoon][:id]
      engine.enclose(chrysalis_id: engine.create_chrysalis(chrysalis_type: :leaf, content: 'c2')[:chrysalis][:id],
                     cocoon_id:    ideal_cocoon)
      cid2 = engine.instance_variable_get(:@chrysalises).values.last.id
      result = engine.incubate(chrysalis_id: cid2)
      expect(result[:progress]).to be_within(0.01).of(0.18)
    end
  end

  describe '#force_emerge' do
    it 'forces butterfly regardless of progress' do
      result = engine.force_emerge(chrysalis_id: chrysalis_id)
      expect(result[:success]).to be true
      expect(result[:stage]).to eq(:butterfly)
    end

    it 'returns failure for unknown chrysalis' do
      result = engine.force_emerge(chrysalis_id: 'bad-id')
      expect(result[:success]).to be false
    end
  end

  describe '#natural_emerge' do
    context 'when not ready' do
      it 'returns failure with :not_ready reason' do
        result = engine.natural_emerge(chrysalis_id: chrysalis_id)
        expect(result[:success]).to be false
        expect(result[:reason]).to eq(:not_ready)
      end
    end

    context 'when ready (progress >= EMERGENCE_THRESHOLD)' do
      before do
        engine.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id)
        12.times { engine.incubate(chrysalis_id: chrysalis_id) }
      end

      it 'successfully emerges when progress is sufficient' do
        result = engine.natural_emerge(chrysalis_id: chrysalis_id)
        expect(result[:success]).to be true
        expect(result[:stage]).to eq(:butterfly)
      end
    end

    it 'returns failure for unknown chrysalis' do
      result = engine.natural_emerge(chrysalis_id: 'bad-id')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#disturb_cocoon' do
    before do
      engine.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id)
    end

    it 'reduces protection of sheltered chrysalises' do
      engine.disturb_cocoon(cocoon_id: cocoon_id, force: 0.1)
      c = engine.instance_variable_get(:@chrysalises)[chrysalis_id]
      expect(c.protection).to be < 0.8
    end

    it 'returns disturbed array with chrysalis info' do
      result = engine.disturb_cocoon(cocoon_id: cocoon_id, force: 0.1)
      expect(result[:disturbed]).not_to be_empty
      expect(result[:disturbed].first[:chrysalis_id]).to eq(chrysalis_id)
    end

    it 'returns failure for unknown cocoon' do
      result = engine.disturb_cocoon(cocoon_id: 'bad-id', force: 0.1)
      expect(result[:success]).to be false
    end
  end

  describe '#incubate_all!' do
    it 'incubates all cocooned and transforming chrysalises' do
      cid2 = engine.create_chrysalis(chrysalis_type: :bark, content: 'idea 2')[:chrysalis][:id]
      cid3 = engine.create_chrysalis(chrysalis_type: :leaf, content: 'idea 3')[:chrysalis][:id]
      coc2 = engine.create_cocoon(environment: 'forest')[:cocoon][:id]
      engine.enclose(chrysalis_id: cid2, cocoon_id: coc2)
      engine.enclose(chrysalis_id: cid3, cocoon_id: coc2)
      result = engine.incubate_all!
      expect(result[:success]).to be true
      expect(result[:incubated]).to eq(2)
    end

    it 'returns empty results when no eligible chrysalises' do
      result = engine.incubate_all!
      expect(result[:incubated]).to eq(0)
    end
  end

  describe '#butterflies' do
    it 'returns empty array initially' do
      expect(engine.butterflies).to eq([])
    end

    it 'returns emerged butterflies' do
      engine.force_emerge(chrysalis_id: chrysalis_id)
      expect(engine.butterflies.size).to eq(1)
    end
  end

  describe '#metamorphosis_report' do
    it 'returns a hash with report keys' do
      result = engine.metamorphosis_report
      expect(result).to include(
        :total_chrysalises,
        :total_cocoons,
        :butterflies_count,
        :premature_count,
        :avg_beauty,
        :avg_progress,
        :cocooned_count,
        :transforming_count
      )
    end

    it 'reflects created chrysalises and cocoons' do
      engine.create_chrysalis(chrysalis_type: :silk, content: 'counted')
      engine.create_cocoon(environment: 'a')
      engine.create_cocoon(environment: 'b')
      result = engine.metamorphosis_report
      expect(result[:total_chrysalises]).to eq(1)
      expect(result[:total_cocoons]).to eq(2)
    end

    it 'counts butterflies correctly' do
      engine.force_emerge(chrysalis_id: chrysalis_id)
      report = engine.metamorphosis_report
      expect(report[:butterflies_count]).to eq(1)
    end

    it 'returns avg_beauty 0.0 when no butterflies' do
      expect(engine.metamorphosis_report[:avg_beauty]).to eq(0.0)
    end

    it 'returns avg_progress 0.0 when no chrysalises' do
      empty_engine = described_class.new
      expect(empty_engine.metamorphosis_report[:avg_progress]).to eq(0.0)
    end
  end
end
