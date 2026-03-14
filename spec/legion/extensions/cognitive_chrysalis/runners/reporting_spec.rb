# frozen_string_literal: true

# Tests focused on status reporting and list operations
RSpec.describe 'Metamorphosis status reporting' do
  let(:engine) { Legion::Extensions::CognitiveChrysalis::Helpers::MetamorphosisEngine.new }
  let(:runner) { Legion::Extensions::CognitiveChrysalis::Runners::CognitiveChrysalis }

  describe 'list_chrysalises' do
    it 'returns empty list for a fresh engine' do
      result = runner.list_chrysalises(engine: engine)
      expect(result[:success]).to be true
      expect(result[:chrysalises]).to eq([])
      expect(result[:count]).to eq(0)
    end

    it 'lists all created chrysalises with their hashes' do
      runner.create_chrysalis(chrysalis_type: :silk, content: 'alpha', engine: engine)
      runner.create_chrysalis(chrysalis_type: :paper, content: 'beta', engine: engine)
      result = runner.list_chrysalises(engine: engine)
      expect(result[:count]).to eq(2)
      types = result[:chrysalises].map { |c| c[:chrysalis_type] }
      expect(types).to contain_exactly(:silk, :paper)
    end

    it 'includes chrysalis details in each entry' do
      runner.create_chrysalis(chrysalis_type: :bark, content: 'idea', engine: engine)
      c = runner.list_chrysalises(engine: engine)[:chrysalises].first
      expect(c).to have_key(:id)
      expect(c).to have_key(:stage)
      expect(c).to have_key(:transformation_progress)
      expect(c).to have_key(:beauty)
    end
  end

  describe 'metamorphosis_status' do
    it 'returns success: true' do
      expect(runner.metamorphosis_status(engine: engine)[:success]).to be true
    end

    it 'shows zeroed counts for empty engine' do
      status = runner.metamorphosis_status(engine: engine)
      expect(status[:total_chrysalises]).to eq(0)
      expect(status[:butterflies_count]).to eq(0)
      expect(status[:premature_count]).to eq(0)
    end

    it 'shows correct butterflies_count after natural emergence' do
      cid = runner.create_chrysalis(chrysalis_type: :leaf, content: 'c', engine: engine)[:chrysalis][:id]
      coc = runner.create_cocoon(environment: 'park', engine: engine)[:cocoon][:id]
      runner.enclose(chrysalis_id: cid, cocoon_id: coc, engine: engine)
      12.times { runner.incubate(chrysalis_id: cid, engine: engine) }
      runner.emerge(chrysalis_id: cid, engine: engine)
      expect(runner.metamorphosis_status(engine: engine)[:butterflies_count]).to eq(1)
    end

    it 'shows correct premature_count after forced emergence' do
      cid = runner.create_chrysalis(chrysalis_type: :silk, content: 'forced', engine: engine)[:chrysalis][:id]
      runner.emerge(chrysalis_id: cid, force: true, engine: engine)
      expect(runner.metamorphosis_status(engine: engine)[:premature_count]).to eq(1)
    end

    it 'includes total_cocoons' do
      runner.create_cocoon(environment: 'a', engine: engine)
      runner.create_cocoon(environment: 'b', engine: engine)
      expect(runner.metamorphosis_status(engine: engine)[:total_cocoons]).to eq(2)
    end

    it 'includes avg_beauty as 0.0 when no butterflies' do
      runner.create_chrysalis(chrysalis_type: :bark, content: 'c', engine: engine)
      expect(runner.metamorphosis_status(engine: engine)[:avg_beauty]).to eq(0.0)
    end

    it 'includes avg_progress > 0.0 after incubation' do
      cid = runner.create_chrysalis(chrysalis_type: :paper, content: 'p', engine: engine)[:chrysalis][:id]
      coc = runner.create_cocoon(environment: 'env', engine: engine)[:cocoon][:id]
      runner.enclose(chrysalis_id: cid, cocoon_id: coc, engine: engine)
      runner.incubate(chrysalis_id: cid, engine: engine)
      expect(runner.metamorphosis_status(engine: engine)[:avg_progress]).to be > 0.0
    end
  end
end
