# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Client do
  subject(:client) { described_class.new }

  it 'responds to create_chrysalis' do
    expect(client).to respond_to(:create_chrysalis)
  end

  it 'responds to create_cocoon' do
    expect(client).to respond_to(:create_cocoon)
  end

  it 'responds to spin' do
    expect(client).to respond_to(:spin)
  end

  it 'responds to enclose' do
    expect(client).to respond_to(:enclose)
  end

  it 'responds to incubate' do
    expect(client).to respond_to(:incubate)
  end

  it 'responds to emerge' do
    expect(client).to respond_to(:emerge)
  end

  it 'responds to disturb' do
    expect(client).to respond_to(:disturb)
  end

  it 'responds to list_chrysalises' do
    expect(client).to respond_to(:list_chrysalises)
  end

  it 'responds to metamorphosis_status' do
    expect(client).to respond_to(:metamorphosis_status)
  end

  it 'exposes the engine as a MetamorphosisEngine' do
    expect(client.engine).to be_a(Legion::Extensions::CognitiveChrysalis::Helpers::MetamorphosisEngine)
  end

  it 'uses the same engine for all calls by default' do
    client.create_chrysalis(chrysalis_type: :silk, content: 'c1')
    status = client.metamorphosis_status
    expect(status[:total_chrysalises]).to eq(1)
  end

  describe 'full lifecycle via client default engine' do
    it 'creates a chrysalis, encloses it, incubates it, and emerges it' do
      cid = client.create_chrysalis(chrysalis_type: :silk, content: 'an insight')[:chrysalis][:id]
      coc = client.create_cocoon(environment: 'forest')[:cocoon][:id]
      client.enclose(chrysalis_id: cid, cocoon_id: coc)
      12.times { client.incubate(chrysalis_id: cid) }
      result = client.emerge(chrysalis_id: cid)
      expect(result[:stage]).to eq(:butterfly)
    end

    it 'reports metamorphosis status after activity' do
      client.create_chrysalis(chrysalis_type: :leaf, content: 'leaf thought')
      status = client.metamorphosis_status
      expect(status[:total_chrysalises]).to eq(1)
    end

    it 'can disturb a cocoon and observe effects' do
      cid = client.create_chrysalis(chrysalis_type: :underground, content: 'idea')[:chrysalis][:id]
      coc = client.create_cocoon(environment: 'cave')[:cocoon][:id]
      client.enclose(chrysalis_id: cid, cocoon_id: coc)
      result = client.disturb(cocoon_id: coc, force: 1.0)
      expect(result[:success]).to be true
    end

    it 'lists created chrysalises' do
      client.create_chrysalis(chrysalis_type: :bark, content: 'a')
      client.create_chrysalis(chrysalis_type: :paper, content: 'b')
      result = client.list_chrysalises
      expect(result[:count]).to eq(2)
    end
  end
end
