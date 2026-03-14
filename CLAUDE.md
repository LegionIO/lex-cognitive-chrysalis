# lex-cognitive-chrysalis

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Metamorphic identity transformation for LegionIO agents. Models structured dissolution and reformation cycles: ideas or identity facets enter a chrysalis, transform through protected incubation, and emerge as something qualitatively different. Premature emergence (forced before transformation is complete) reduces beauty and can produce damaged outputs.

## Gem Info

- **Gem name**: `lex-cognitive-chrysalis`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::CognitiveChrysalis`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_chrysalis/
  cognitive_chrysalis.rb
  version.rb
  client.rb
  helpers/
    constants.rb
    chrysalis.rb
    cocoon.rb
    metamorphosis_engine.rb
  runners/
    cognitive_chrysalis.rb
```

## Key Constants

From `helpers/constants.rb`:

- `LIFE_STAGES` — `%i[larva spinning cocooned transforming emerging butterfly]`
- `CHRYSALIS_TYPES` — `%i[silk paper bark leaf underground]`
- `MAX_CHRYSALISES` = `200`, `MAX_BUTTERFLIES` = `500`
- `TRANSFORMATION_RATE` = `0.08`, `PROTECTION_DECAY` = `0.03`
- `EMERGENCE_THRESHOLD` = `0.9` (transformation_progress must reach this for natural emergence)
- `PREMATURE_PENALTY` = `0.4` (beauty penalty for forced emergence before threshold)
- `STAGE_LABELS` — progress-to-stage mapping: `0.0-0.20` = `:larva`, `0.20-0.40` = `:spinning`, up to `0.90-1.0` = `:butterfly`
- `BEAUTY_LABELS` — `0.85+` = `:magnificent`, `0.65` = `:beautiful`, `0.40` = `:striking`, `0.20` = `:plain`, below = `:dull`

## Runners

All methods in `Runners::CognitiveChrysalis` (`extend self`):

- `create_chrysalis(chrysalis_type: :silk, content: '')` — creates a new chrysalis in `:larva` stage
- `create_cocoon(environment: 'default', temperature: 0.5, humidity: 0.5)` — creates a protective cocoon environment
- `spin(chrysalis_id:)` — advances chrysalis from `:larva` to `:spinning`; must be in `:larva` state
- `enclose(chrysalis_id:, cocoon_id:)` — places a chrysalis inside a cocoon
- `incubate(chrysalis_id:)` — advances transformation progress by `TRANSFORMATION_RATE`
- `incubate_all` — incubates all eligible (non-butterfly) chrysalises
- `emerge(chrysalis_id:, force: false)` — natural emergence requires `transformation_progress >= 0.9`; forced emergence applies `PREMATURE_PENALTY` to beauty
- `disturb(cocoon_id:, force: 0.1)` — degrades cocoon protection; if protection drops to 0 during active transformation, triggers forced emergence
- `list_chrysalises` — all chrysalises with current state
- `metamorphosis_status` — aggregate report

## Helpers

- `MetamorphosisEngine` — manages chrysalises and cocoons.
- `Chrysalis` — state machine through `LIFE_STAGES`. `transform!(rate)` advances progress and beauty. `emerge!(force:)` checks threshold; forced emergence sets `@premature = true` and applies beauty penalty. `disturb!(force)` degrades protection.
- `Cocoon` — protective environment with temperature, humidity, protection score.

## Integration Points

- `lex-cognitive-cocoon` is a related but distinct extension — cocoon models the protective encapsulation of fragile ideas; chrysalis models the full metamorphic transformation lifecycle (larva through butterfly). They can compose: a cocoon provides the environment, a chrysalis undergoes the transformation inside it.
- `lex-memory` can hold chrysalis IDs as pending transformation traces — ideas that are not ready for activation but are undergoing gradual consolidation.
- `lex-coldstart` imprint window is conceptually similar to the chrysalis state: ideas absorbed during cold start are in a protected transformation phase.

## Development Notes

- Stage progression is strictly one-directional: larva -> spinning -> cocooned -> transforming -> emerging -> butterfly. No regression.
- `spin!` on a non-larva chrysalis raises `ArgumentError`. The runner returns `{ success: false, reason: e.message }`.
- `transform!` auto-advances stage by comparing current stage rank vs progress-derived stage rank, taking the maximum. This means a chrysalis never regresses stages even if progress somehow decreases.
- `premature?` convenience predicate: `butterfly? && beauty < 0.5`.
- `beauty` is computed as `transformation_progress * 0.9` during incubation; full beauty (1.0) only on natural emergence.
