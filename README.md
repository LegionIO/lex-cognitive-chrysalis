# lex-cognitive-chrysalis

Metamorphic identity transformation for LegionIO agents. Models structured dissolution and reformation cycles for the cognitive architecture.

## What It Does

Some ideas and identity facets require deep transformation before they are useful — not incremental improvement, but dissolution and reformation into something qualitatively different. This extension models that metamorphic process: a larva enters a protective chrysalis, incubates through multiple transformation stages, and emerges as a butterfly. Emergence quality (beauty) depends on whether the transformation ran to completion or was forced prematurely.

Five chrysalis types provide different protection levels: silk (0.6), leaf (protected), bark (0.7), paper, and underground (highest). External disturbances can degrade cocoon protection and trigger premature emergence with a beauty penalty.

## Usage

```ruby
client = Legion::Extensions::CognitiveChrysalis::Client.new

cocoon = client.create_cocoon(environment: 'quiet_space', temperature: 0.6, humidity: 0.5)

chrysalis = client.create_chrysalis(
  chrysalis_type: :silk,
  content: 'core identity belief under revision'
)

client.spin(chrysalis_id: chrysalis[:chrysalis][:id])
client.enclose(chrysalis_id: chrysalis[:chrysalis][:id],
               cocoon_id: cocoon[:cocoon][:id])

10.times { client.incubate(chrysalis_id: chrysalis[:chrysalis][:id]) }

client.emerge(chrysalis_id: chrysalis[:chrysalis][:id])
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
