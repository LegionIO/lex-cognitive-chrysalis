# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Runners::CognitiveChrysalis do
  subject(:runner) { described_class }

  let(:engine) { Legion::Extensions::CognitiveChrysalis::Helpers::MetamorphosisEngine.new }

  describe '.create_chrysalis' do
    it 'returns success: true with a valid type' do
      result = runner.create_chrysalis(chrysalis_type: :silk, content: 'thought', engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns success: false for an invalid type' do
      result = runner.create_chrysalis(chrysalis_type: :invalid, content: 'x', engine: engine)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:invalid_type)
    end

    it 'returns the valid_types list on invalid type' do
      result = runner.create_chrysalis(chrysalis_type: :invalid, content: 'x', engine: engine)
      expect(result[:valid_types]).to eq(Legion::Extensions::CognitiveChrysalis::Helpers::Constants::CHRYSALIS_TYPES)
    end

    it 'defaults chrysalis_type to :silk when not provided' do
      result = runner.create_chrysalis(content: 'default', engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '.create_cocoon' do
    it 'returns success: true' do
      result = runner.create_cocoon(environment: 'meadow', engine: engine)
      expect(result[:success]).to be true
    end

    it 'defaults environment to "default"' do
      result = runner.create_cocoon(engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '.spin' do
    let(:chrysalis_id) { runner.create_chrysalis(chrysalis_type: :silk, content: 'c', engine: engine)[:chrysalis][:id] }

    it 'returns success: true for a valid chrysalis' do
      result = runner.spin(chrysalis_id: chrysalis_id, engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns failure for missing chrysalis_id' do
      result = runner.spin(chrysalis_id: nil, engine: engine)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:missing_chrysalis_id)
    end

    it 'returns failure for unknown chrysalis_id' do
      result = runner.spin(chrysalis_id: 'ghost', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '.enclose' do
    let(:chrysalis_id) { runner.create_chrysalis(chrysalis_type: :leaf, content: 'c', engine: engine)[:chrysalis][:id] }
    let(:cocoon_id)    { runner.create_cocoon(environment: 'wood', engine: engine)[:cocoon][:id] }

    it 'encloses a chrysalis in a cocoon' do
      result = runner.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:stage]).to eq(:cocooned)
    end

    it 'returns failure for missing chrysalis_id' do
      result = runner.enclose(chrysalis_id: nil, cocoon_id: cocoon_id, engine: engine)
      expect(result[:success]).to be false
    end

    it 'returns failure for missing cocoon_id' do
      result = runner.enclose(chrysalis_id: chrysalis_id, cocoon_id: nil, engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '.incubate' do
    let(:chrysalis_id) do
      runner.create_chrysalis(chrysalis_type: :paper, content: 'c', engine: engine)[:chrysalis][:id]
    end
    let(:cocoon_id) { runner.create_cocoon(environment: 'nest', engine: engine)[:cocoon][:id] }

    before { runner.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id, engine: engine) }

    it 'increases progress' do
      result = runner.incubate(chrysalis_id: chrysalis_id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:progress]).to be > 0.0
    end

    it 'returns failure for missing chrysalis_id' do
      result = runner.incubate(chrysalis_id: nil, engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '.emerge' do
    let(:chrysalis_id) { runner.create_chrysalis(chrysalis_type: :bark, content: 'c', engine: engine)[:chrysalis][:id] }
    let(:cocoon_id)    { runner.create_cocoon(environment: 'oak', engine: engine)[:cocoon][:id] }

    before do
      runner.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id, engine: engine)
      12.times { runner.incubate(chrysalis_id: chrysalis_id, engine: engine) }
    end

    it 'emerges naturally when ready' do
      result = runner.emerge(chrysalis_id: chrysalis_id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:stage]).to eq(:butterfly)
    end

    it 'force-emerges when force: true' do
      cid2 = runner.create_chrysalis(chrysalis_type: :silk, content: 'fresh', engine: engine)[:chrysalis][:id]
      result = runner.emerge(chrysalis_id: cid2, force: true, engine: engine)
      expect(result[:success]).to be true
      expect(result[:stage]).to eq(:butterfly)
    end

    it 'returns failure for missing chrysalis_id' do
      result = runner.emerge(chrysalis_id: nil, engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '.disturb' do
    let(:chrysalis_id) { runner.create_chrysalis(chrysalis_type: :silk, content: 'c', engine: engine)[:chrysalis][:id] }
    let(:cocoon_id)    { runner.create_cocoon(environment: 'pond', engine: engine)[:cocoon][:id] }

    before { runner.enclose(chrysalis_id: chrysalis_id, cocoon_id: cocoon_id, engine: engine) }

    it 'disturbs the cocoon' do
      result = runner.disturb(cocoon_id: cocoon_id, force: 0.1, engine: engine)
      expect(result[:success]).to be true
      expect(result[:disturbed]).not_to be_empty
    end

    it 'returns failure for missing cocoon_id' do
      result = runner.disturb(cocoon_id: nil, engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '.list_chrysalises' do
    it 'returns success: true' do
      result = runner.list_chrysalises(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns empty array when no chrysalises' do
      result = runner.list_chrysalises(engine: engine)
      expect(result[:chrysalises]).to eq([])
    end

    it 'lists all created chrysalises' do
      runner.create_chrysalis(chrysalis_type: :silk, content: 'one', engine: engine)
      runner.create_chrysalis(chrysalis_type: :paper, content: 'two', engine: engine)
      result = runner.list_chrysalises(engine: engine)
      expect(result[:count]).to eq(2)
    end
  end

  describe '.metamorphosis_status' do
    it 'returns success: true' do
      result = runner.metamorphosis_status(engine: engine)
      expect(result[:success]).to be true
    end

    it 'includes report keys' do
      result = runner.metamorphosis_status(engine: engine)
      expect(result).to include(:total_chrysalises, :butterflies_count, :avg_beauty)
    end
  end
end
