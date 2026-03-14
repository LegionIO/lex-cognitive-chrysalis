# frozen_string_literal: true

require 'legion/extensions/cognitive_chrysalis/client'

RSpec.describe Legion::Extensions::CognitiveChrysalis::Client do
  let(:client) { described_class.new }
  let(:engine) { Legion::Extensions::CognitiveChrysalis::Helpers::ChrysalisEngine.new }
  let(:client_with_engine) { described_class.new(engine: engine) }
  let(:phase_mod) { Legion::Extensions::CognitiveChrysalis::Helpers::TransformationPhase }

  def make_phase(name, ticks)
    phase_mod.new_phase(name: name, duration_ticks: ticks)
  end

  it 'responds to transformation runner methods' do
    expect(client).to respond_to(:begin_transformation)
    expect(client).to respond_to(:advance_cycle)
    expect(client).to respond_to(:offline_capabilities)
    expect(client).to respond_to(:restore_capabilities)
    expect(client).to respond_to(:record_emergence)
  end

  it 'responds to reporting runner methods' do
    expect(client).to respond_to(:transformation_history)
    expect(client).to respond_to(:most_transformed_domains)
    expect(client).to respond_to(:metamorphic_readiness)
    expect(client).to respond_to(:chrysalis_report)
    expect(client).to respond_to(:tick_cooldown)
  end

  it 'uses provided engine' do
    result = client_with_engine.begin_transformation(trigger: 'test', domain: :cognitive)
    expect(result[:success]).to be true
    expect(engine.active_cycles.size).to eq(1)
  end

  it 'runs a full metamorphic lifecycle' do
    phases = [
      make_phase(:larval, 1),
      make_phase(:dissolution, 1),
      make_phase(:chrysalis, 1),
      make_phase(:reformation, 1),
      make_phase(:emergence, 1)
    ]

    started = client_with_engine.begin_transformation(trigger: 'deep insight', domain: :fundamental, phases: phases)
    expect(started[:success]).to be true
    cycle_id = started[:cycle_id]

    5.times { client_with_engine.advance_cycle(cycle_id: cycle_id) }

    history = client_with_engine.transformation_history
    expect(history[:count]).to eq(1)
    expect(history[:history].first[:status]).to eq(:emerged)

    report = client_with_engine.chrysalis_report
    expect(report[:report][:completed_cycles]).to eq(1)
    expect(report[:report][:cooldown_remaining]).to eq(
      Legion::Extensions::CognitiveChrysalis::Helpers::Constants::COOLDOWN_CYCLES
    )
  end
end
