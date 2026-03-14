# frozen_string_literal: true

# Integration tests for the full metamorphosis pipeline
RSpec.describe 'Full metamorphosis pipeline integration' do
  let(:engine) { Legion::Extensions::CognitiveChrysalis::Helpers::MetamorphosisEngine.new }
  let(:runner) { Legion::Extensions::CognitiveChrysalis::Runners::CognitiveChrysalis }

  it 'creates and fully transforms a chrysalis through the natural emergence path' do
    cid = runner.create_chrysalis(chrysalis_type: :silk, content: 'deep insight', engine: engine)[:chrysalis][:id]
    coc = runner.create_cocoon(environment: 'sacred_grove', engine: engine)[:cocoon][:id]
    runner.enclose(chrysalis_id: cid, cocoon_id: coc, engine: engine)

    # Incubate until ready (needs ~12 steps with base rate 0.08 to exceed 0.9)
    result = nil
    12.times { result = runner.incubate(chrysalis_id: cid, engine: engine) }
    expect(result[:progress]).to be >= Legion::Extensions::CognitiveChrysalis::Helpers::Constants::EMERGENCE_THRESHOLD

    result = runner.emerge(chrysalis_id: cid, engine: engine)
    expect(result[:success]).to be true
    expect(result[:stage]).to eq(:butterfly)
    expect(result[:premature]).to be false
  end

  it 'reports correct stats after full transformation' do
    cid = runner.create_chrysalis(chrysalis_type: :leaf, content: 'wisdom', engine: engine)[:chrysalis][:id]
    coc = runner.create_cocoon(environment: 'canopy', engine: engine)[:cocoon][:id]
    runner.enclose(chrysalis_id: cid, cocoon_id: coc, engine: engine)
    12.times { runner.incubate(chrysalis_id: cid, engine: engine) }
    runner.emerge(chrysalis_id: cid, engine: engine)

    status = runner.metamorphosis_status(engine: engine)
    expect(status[:butterflies_count]).to eq(1)
    expect(status[:premature_count]).to eq(0)
    expect(status[:avg_beauty]).to eq(1.0)
  end

  it 'handles multiple concurrent chrysalises in the same engine' do
    ids = (1..3).map do |i|
      cid = runner.create_chrysalis(chrysalis_type: :bark, content: "idea #{i}", engine: engine)[:chrysalis][:id]
      coc = runner.create_cocoon(environment: "env_#{i}", engine: engine)[:cocoon][:id]
      runner.enclose(chrysalis_id: cid, cocoon_id: coc, engine: engine)
      cid
    end

    12.times { runner.incubate_all(engine: engine) }
    ids.each { |cid| runner.emerge(chrysalis_id: cid, engine: engine) }

    status = runner.metamorphosis_status(engine: engine)
    expect(status[:butterflies_count]).to eq(3)
  end

  it 'incubate_all applies modifiers from individual cocoons' do
    cid1 = runner.create_chrysalis(chrysalis_type: :silk, content: 'c1', engine: engine)[:chrysalis][:id]
    coc1 = runner.create_cocoon(environment: 'ideal', temperature: 0.55, humidity: 0.55, engine: engine)[:cocoon][:id]
    runner.enclose(chrysalis_id: cid1, cocoon_id: coc1, engine: engine)

    result = runner.incubate_all(engine: engine)
    expect(result[:incubated]).to eq(1)
    c = engine.instance_variable_get(:@chrysalises)[cid1]
    expect(c.transformation_progress).to be > Legion::Extensions::CognitiveChrysalis::Helpers::Constants::TRANSFORMATION_RATE
  end

  it 'disturbing a cocoon mid-transformation can force premature emergence' do
    cid = runner.create_chrysalis(chrysalis_type: :underground, content: 'fragile', engine: engine)[:chrysalis][:id]
    coc = runner.create_cocoon(environment: 'unstable', engine: engine)[:cocoon][:id]
    runner.enclose(chrysalis_id: cid, cocoon_id: coc, engine: engine)
    3.times { runner.incubate(chrysalis_id: cid, engine: engine) }
    runner.disturb(cocoon_id: coc, force: 1.0, engine: engine)

    c = engine.instance_variable_get(:@chrysalises)[cid]
    expect(c.butterfly?).to be true
    expect(c.premature?).to be true
  end
end
