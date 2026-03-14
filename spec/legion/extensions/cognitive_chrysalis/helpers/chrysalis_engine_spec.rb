# frozen_string_literal: true

# This file intentionally tests the MetamorphosisEngine via focused unit scenarios
# previously covered by a now-replaced helper. See metamorphosis_engine_spec.rb for full coverage.

RSpec.describe 'MetamorphosisEngine capacity and butterfly tracking' do
  let(:engine) { Legion::Extensions::CognitiveChrysalis::Helpers::MetamorphosisEngine.new }

  it 'tracks butterflies separately from active chrysalises' do
    cid = engine.create_chrysalis(chrysalis_type: :silk, content: 'idea')[:chrysalis][:id]
    engine.force_emerge(chrysalis_id: cid)
    expect(engine.butterflies.size).to eq(1)
    report = engine.metamorphosis_report
    expect(report[:butterflies_count]).to eq(1)
  end

  it 'counts premature butterflies in report' do
    cid = engine.create_chrysalis(chrysalis_type: :paper, content: 'fragile')[:chrysalis][:id]
    engine.force_emerge(chrysalis_id: cid)
    report = engine.metamorphosis_report
    expect(report[:premature_count]).to eq(1)
  end

  it 'returns 0 avg_beauty when no butterflies exist' do
    engine.create_chrysalis(chrysalis_type: :bark, content: 'c')
    expect(engine.metamorphosis_report[:avg_beauty]).to eq(0.0)
  end

  it 'calculates non-zero avg_progress after incubation' do
    cid = engine.create_chrysalis(chrysalis_type: :leaf, content: 'c')[:chrysalis][:id]
    coc = engine.create_cocoon(environment: 'forest')[:cocoon][:id]
    engine.enclose(chrysalis_id: cid, cocoon_id: coc)
    engine.incubate(chrysalis_id: cid)
    expect(engine.metamorphosis_report[:avg_progress]).to be > 0.0
  end

  it 'incubate_all returns success: true even with no chrysalises' do
    expect(engine.incubate_all![:success]).to be true
  end

  it 'disturb_cocoon with full force can trigger forced emergence' do
    cid = engine.create_chrysalis(chrysalis_type: :underground, content: 'deep')[:chrysalis][:id]
    coc = engine.create_cocoon(environment: 'cave')[:cocoon][:id]
    engine.enclose(chrysalis_id: cid, cocoon_id: coc)
    engine.disturb_cocoon(cocoon_id: coc, force: 1.0)
    c = engine.instance_variable_get(:@chrysalises)[cid]
    expect(c.butterfly?).to be true
  end

  it 'applies ideal cocoon modifier, increasing progress faster' do
    cid  = engine.create_chrysalis(chrysalis_type: :silk, content: 'c1')[:chrysalis][:id]
    coc  = engine.create_cocoon(environment: 'ideal', temperature: 0.55, humidity: 0.55)[:cocoon][:id]
    engine.enclose(chrysalis_id: cid, cocoon_id: coc)
    result = engine.incubate(chrysalis_id: cid)
    expect(result[:progress]).to be > Legion::Extensions::CognitiveChrysalis::Helpers::Constants::TRANSFORMATION_RATE
  end
end
