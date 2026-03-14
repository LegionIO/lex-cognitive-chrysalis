# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveChrysalis::Helpers::MetamorphicCycle do
  let(:mod) { described_class }
  let(:phase_mod) { Legion::Extensions::CognitiveChrysalis::Helpers::TransformationPhase }

  def make_phase(name, duration_ticks)
    phase_mod.new_phase(name: name, duration_ticks: duration_ticks)
  end

  describe '.new_cycle' do
    it 'creates a cycle with expected keys' do
      cycle = mod.new_cycle(trigger: 'insight', domain: :cognitive)
      expect(cycle[:cycle_id]).not_to be_nil
      expect(cycle[:trigger]).to eq('insight')
      expect(cycle[:domain]).to eq(:cognitive)
      expect(cycle[:status]).to eq(:incubating)
      expect(cycle[:phases]).to eq([])
      expect(cycle[:current_phase_index]).to eq(0)
      expect(cycle[:dissolution_depth]).to eq(0.0)
      expect(cycle[:emergence_score]).to eq(0.0)
    end

    it 'generates unique cycle ids' do
      a = mod.new_cycle(trigger: 'x', domain: :cognitive)
      b = mod.new_cycle(trigger: 'x', domain: :cognitive)
      expect(a[:cycle_id]).not_to eq(b[:cycle_id])
    end

    it 'raises on invalid domain' do
      expect { mod.new_cycle(trigger: 'x', domain: :unknown) }.to raise_error(ArgumentError, /invalid domain/)
    end
  end

  describe '.advance!' do
    it 'transitions from incubating to active on first advance' do
      phase = make_phase(:larval, 5)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [phase])
      updated = mod.advance!(cycle)
      expect(updated[:status]).to eq(:active)
    end

    it 'sets started_at on first advance' do
      phase = make_phase(:larval, 5)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [phase])
      updated = mod.advance!(cycle)
      expect(updated[:started_at]).not_to be_nil
    end

    it 'does not mutate original cycle' do
      phase = make_phase(:larval, 5)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [phase])
      mod.advance!(cycle)
      expect(cycle[:status]).to eq(:incubating)
    end

    it 'advances to next phase when current phase completes' do
      p1 = make_phase(:larval, 1)
      p2 = make_phase(:growth, 5)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1, p2])
      updated = mod.advance!(cycle)
      expect(updated[:current_phase_index]).to eq(1)
      expect(updated[:status]).to eq(:transforming)
    end

    it 'marks cycle as emerged when all phases complete' do
      p1 = make_phase(:emergence, 1)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1])
      updated = mod.advance!(cycle)
      expect(updated[:status]).to eq(:emerged)
      expect(updated[:completed_at]).not_to be_nil
    end

    it 'does not advance an emerged cycle' do
      p1 = make_phase(:emergence, 1)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1])
      emerged = mod.advance!(cycle)
      again = mod.advance!(emerged)
      expect(again[:status]).to eq(:emerged)
    end

    it 'accumulates dissolution_depth during dissolution phase' do
      p1 = make_phase(:dissolution, 5)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1])
      updated = mod.advance!(cycle)
      expect(updated[:dissolution_depth]).to be > 0.0
    end

    it 'accumulates emergence_score during reformation phase' do
      p1 = make_phase(:reformation, 5)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1])
      updated = mod.advance!(cycle)
      expect(updated[:emergence_score]).to be > 0.0
    end
  end

  describe '.current_phase' do
    it 'returns the current phase' do
      p1 = make_phase(:larval, 5)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1])
      expect(mod.current_phase(cycle)[:name]).to eq(:larval)
    end

    it 'returns nil for empty phases' do
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive)
      expect(mod.current_phase(cycle)).to be_nil
    end
  end

  describe '.progress' do
    it 'returns 0.0 for a fresh cycle with phases' do
      p1 = make_phase(:larval, 10)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1])
      expect(mod.progress(cycle)).to eq(0.0)
    end

    it 'returns 0.0 for empty phases' do
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive)
      expect(mod.progress(cycle)).to eq(0.0)
    end

    it 'returns 1.0 for fully emerged cycle' do
      p1 = make_phase(:emergence, 1)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1])
      emerged = mod.advance!(cycle)
      expect(mod.progress(emerged)).to eq(1.0)
    end
  end

  describe '.transformed?' do
    it 'returns false for incubating cycle' do
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive)
      expect(mod.transformed?(cycle)).to be false
    end

    it 'returns true for emerged cycle with high emergence score' do
      p1 = make_phase(:reformation, 1)
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive, phases: [p1])
      cycle[:emergence_score] = 0.95
      cycle[:status] = :emerged
      expect(mod.transformed?(cycle)).to be true
    end

    it 'returns false for emerged cycle with low emergence score' do
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive)
      cycle[:status] = :emerged
      cycle[:emergence_score] = 0.5
      expect(mod.transformed?(cycle)).to be false
    end
  end

  describe '.dissolution_depth' do
    it 'returns 0.0 for new cycle' do
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive)
      expect(mod.dissolution_depth(cycle)).to eq(0.0)
    end
  end

  describe '.emergence_readiness' do
    it 'returns 0.0 for new cycle' do
      cycle = mod.new_cycle(trigger: 'test', domain: :cognitive)
      expect(mod.emergence_readiness(cycle)).to eq(0.0)
    end
  end
end
