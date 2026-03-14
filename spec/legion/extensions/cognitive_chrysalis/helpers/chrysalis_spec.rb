# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Helpers::Chrysalis do
  subject(:chrysalis) { described_class.new(chrysalis_type: :silk, content: 'a new idea') }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(chrysalis.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets chrysalis_type to the given symbol' do
      expect(chrysalis.chrysalis_type).to eq(:silk)
    end

    it 'sets content to the given string' do
      expect(chrysalis.content).to eq('a new idea')
    end

    it 'starts in :larva stage' do
      expect(chrysalis.stage).to eq(:larva)
    end

    it 'starts with transformation_progress 0.0' do
      expect(chrysalis.transformation_progress).to eq(0.0)
    end

    it 'starts with protection 0.8' do
      expect(chrysalis.protection).to eq(0.8)
    end

    it 'starts with beauty 0.0' do
      expect(chrysalis.beauty).to eq(0.0)
    end

    it 'records created_at as a Time' do
      expect(chrysalis.created_at).to be_a(Time)
    end
  end

  describe '#spin!' do
    it 'transitions stage from :larva to :spinning' do
      chrysalis.spin!
      expect(chrysalis.stage).to eq(:spinning)
    end

    it 'returns true' do
      expect(chrysalis.spin!).to be true
    end

    it 'raises ArgumentError when not in :larva stage' do
      chrysalis.spin!
      expect { chrysalis.spin! }.to raise_error(ArgumentError)
    end
  end

  describe '#cocoon!' do
    before { chrysalis.spin! }

    it 'transitions stage from :spinning to :cocooned' do
      chrysalis.cocoon!
      expect(chrysalis.stage).to eq(:cocooned)
    end

    it 'returns true' do
      expect(chrysalis.cocoon!).to be true
    end

    it 'raises ArgumentError when not in :spinning stage' do
      chrysalis.cocoon!
      expect { chrysalis.cocoon! }.to raise_error(ArgumentError)
    end
  end

  describe '#transform!' do
    it 'increments transformation_progress by TRANSFORMATION_RATE by default' do
      chrysalis.transform!
      expect(chrysalis.transformation_progress).to be_within(0.0001).of(0.08)
    end

    it 'accepts a custom rate' do
      chrysalis.transform!(0.2)
      expect(chrysalis.transformation_progress).to be_within(0.0001).of(0.2)
    end

    it 'increases beauty proportionally' do
      chrysalis.transform!(0.5)
      expect(chrysalis.beauty).to be > 0.0
    end

    it 'clamps transformation_progress to 1.0' do
      15.times { chrysalis.transform! }
      expect(chrysalis.transformation_progress).to eq(1.0)
    end

    it 'returns false when already a butterfly' do
      chrysalis.transform!(1.0)
      chrysalis.emerge!
      expect(chrysalis.transform!).to be false
    end

    it 'updates stage when progress crosses 0.6 threshold' do
      chrysalis.transform!(0.65)
      expect(chrysalis.stage).to eq(:transforming)
    end

    it 'updates stage to :emerging when progress crosses 0.8 threshold' do
      chrysalis.transform!(0.85)
      expect(chrysalis.stage).to eq(:emerging)
    end
  end

  describe '#emerge!' do
    context 'when transformation_progress >= EMERGENCE_THRESHOLD' do
      before { chrysalis.transform!(0.95) }

      it 'transitions to :butterfly' do
        chrysalis.emerge!
        expect(chrysalis.stage).to eq(:butterfly)
      end

      it 'sets beauty to 1.0' do
        chrysalis.emerge!
        expect(chrysalis.beauty).to eq(1.0)
      end

      it 'returns true' do
        expect(chrysalis.emerge!).to be true
      end
    end

    context 'when transformation_progress < EMERGENCE_THRESHOLD' do
      it 'returns false without forcing' do
        chrysalis.transform!(0.5)
        expect(chrysalis.emerge!).to be false
      end

      it 'stage remains unchanged' do
        chrysalis.transform!(0.5)
        stage_before = chrysalis.stage
        chrysalis.emerge!
        expect(chrysalis.stage).to eq(stage_before)
      end
    end

    context 'when forced early' do
      before { chrysalis.transform!(0.3) }

      it 'transitions to :butterfly' do
        chrysalis.emerge!(force: true)
        expect(chrysalis.stage).to eq(:butterfly)
      end

      it 'applies PREMATURE_PENALTY to beauty' do
        beauty_before = chrysalis.beauty
        chrysalis.emerge!(force: true)
        expect(chrysalis.beauty).to be <= beauty_before
      end

      it 'returns true' do
        expect(chrysalis.emerge!(force: true)).to be true
      end
    end
  end

  describe '#decay_protection!' do
    it 'reduces protection by PROTECTION_DECAY' do
      original = chrysalis.protection
      chrysalis.decay_protection!
      expected = (original - Legion::Extensions::CognitiveChrysalis::Helpers::Constants::PROTECTION_DECAY).round(10)
      expect(chrysalis.protection).to be_within(0.0001).of(expected)
    end

    it 'does not go below 0.0' do
      30.times { chrysalis.decay_protection! }
      expect(chrysalis.protection).to eq(0.0)
    end
  end

  describe '#disturb!' do
    it 'reduces protection by the given force' do
      chrysalis.disturb!(0.2)
      expect(chrysalis.protection).to be_within(0.0001).of(0.6)
    end

    it 'forces premature emergence when protection drops to zero for a cocooned chrysalis' do
      chrysalis.spin!
      chrysalis.cocoon!
      chrysalis.disturb!(1.0)
      expect(chrysalis.stage).to eq(:butterfly)
    end

    it 'does not force-emerge a larva when protection hits zero' do
      chrysalis.disturb!(1.0)
      expect(chrysalis.stage).to eq(:larva)
    end
  end

  describe '#butterfly?' do
    it 'returns false before emergence' do
      expect(chrysalis.butterfly?).to be false
    end

    it 'returns true after natural emergence' do
      chrysalis.transform!(1.0)
      chrysalis.emerge!
      expect(chrysalis.butterfly?).to be true
    end
  end

  describe '#cocooned?' do
    it 'returns false initially' do
      expect(chrysalis.cocooned?).to be false
    end

    it 'returns true after cocooning' do
      chrysalis.spin!
      chrysalis.cocoon!
      expect(chrysalis.cocooned?).to be true
    end
  end

  describe '#transforming?' do
    it 'returns false initially' do
      expect(chrysalis.transforming?).to be false
    end

    it 'returns true after sufficient progress' do
      chrysalis.transform!(0.65)
      expect(chrysalis.transforming?).to be true
    end
  end

  describe '#premature?' do
    it 'returns false for a non-butterfly' do
      expect(chrysalis.premature?).to be false
    end

    it 'returns false for a naturally emerged butterfly' do
      chrysalis.transform!(1.0)
      chrysalis.emerge!
      expect(chrysalis.premature?).to be false
    end

    it 'returns true for a forcibly emerged butterfly with low beauty' do
      chrysalis.transform!(0.05)
      chrysalis.emerge!(force: true)
      expect(chrysalis.premature?).to be true
    end
  end

  describe '#stage_label' do
    it 'returns a symbol' do
      expect(chrysalis.stage_label).to be_a(Symbol)
    end

    it 'returns :larva for a fresh chrysalis' do
      expect(chrysalis.stage_label).to eq(:larva)
    end
  end

  describe '#beauty_label' do
    it 'returns :dull for beauty 0.0' do
      expect(chrysalis.beauty_label).to eq(:dull)
    end

    it 'returns :magnificent after natural emergence' do
      chrysalis.transform!(1.0)
      chrysalis.emerge!
      expect(chrysalis.beauty_label).to eq(:magnificent)
    end
  end

  describe '#to_h' do
    it 'returns a hash' do
      expect(chrysalis.to_h).to be_a(Hash)
    end

    it 'includes id, stage, content, chrysalis_type' do
      h = chrysalis.to_h
      expect(h[:id]).to eq(chrysalis.id)
      expect(h[:stage]).to eq(:larva)
      expect(h[:content]).to eq('a new idea')
      expect(h[:chrysalis_type]).to eq(:silk)
    end

    it 'includes transformation_progress and protection and beauty' do
      h = chrysalis.to_h
      expect(h).to have_key(:transformation_progress)
      expect(h).to have_key(:protection)
      expect(h).to have_key(:beauty)
    end

    it 'includes stage_label and beauty_label' do
      h = chrysalis.to_h
      expect(h).to have_key(:stage_label)
      expect(h).to have_key(:beauty_label)
    end

    it 'includes premature and created_at' do
      h = chrysalis.to_h
      expect(h).to have_key(:premature)
      expect(h).to have_key(:created_at)
    end
  end
end
