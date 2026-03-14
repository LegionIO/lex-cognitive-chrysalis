# frozen_string_literal: true

# Tests focused on Chrysalis stage progression through repeated transform! calls
RSpec.describe 'Chrysalis stage progression' do
  let(:chrysalis) { Legion::Extensions::CognitiveChrysalis::Helpers::Chrysalis.new(chrysalis_type: :silk, content: 'journey') }
  let(:rate) { Legion::Extensions::CognitiveChrysalis::Helpers::Constants::TRANSFORMATION_RATE }

  it 'progresses through larva -> spinning -> cocooned -> transforming -> emerging over time' do
    # 0.0 = larva
    expect(chrysalis.stage).to eq(:larva)

    # Cross 0.2 = spinning
    3.times { chrysalis.transform! }
    expect(chrysalis.stage).to eq(:spinning)

    # Cross 0.4 = cocooned
    3.times { chrysalis.transform! }
    expect(chrysalis.stage).to eq(:cocooned)

    # Cross 0.6 = transforming
    3.times { chrysalis.transform! }
    expect(chrysalis.stage).to eq(:transforming)

    # Cross 0.8 = emerging
    3.times { chrysalis.transform! }
    expect(chrysalis.stage).to eq(:emerging)
  end

  it 'can emerge after crossing the threshold' do
    12.times { chrysalis.transform! }
    result = chrysalis.emerge!
    expect(result).to be true
    expect(chrysalis.butterfly?).to be true
  end

  it 'beauty grows with each transform step' do
    beauty_before = chrysalis.beauty
    chrysalis.transform!
    expect(chrysalis.beauty).to be > beauty_before
  end

  it 'stage_label matches transformation_progress' do
    chrysalis.transform!(0.25)
    label = Legion::Extensions::CognitiveChrysalis::Helpers::Constants.label_for(
      Legion::Extensions::CognitiveChrysalis::Helpers::Constants::STAGE_LABELS,
      chrysalis.transformation_progress
    )
    expect(chrysalis.stage_label).to eq(label)
  end

  it 'beauty_label matches beauty' do
    chrysalis.transform!(0.7)
    label = Legion::Extensions::CognitiveChrysalis::Helpers::Constants.label_for(
      Legion::Extensions::CognitiveChrysalis::Helpers::Constants::BEAUTY_LABELS,
      chrysalis.beauty
    )
    expect(chrysalis.beauty_label).to eq(label)
  end

  it 'multiple chrysalises have unique ids' do
    a = Legion::Extensions::CognitiveChrysalis::Helpers::Chrysalis.new(chrysalis_type: :bark, content: 'a')
    b = Legion::Extensions::CognitiveChrysalis::Helpers::Chrysalis.new(chrysalis_type: :bark, content: 'b')
    expect(a.id).not_to eq(b.id)
  end

  it 'premature? is false after natural emergence' do
    12.times { chrysalis.transform! }
    chrysalis.emerge!
    expect(chrysalis.premature?).to be false
  end

  it 'premature? is true after forced emergence from larva stage' do
    chrysalis.emerge!(force: true)
    expect(chrysalis.premature?).to be true
  end
end
