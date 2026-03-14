# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_chrysalis/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-chrysalis'
  spec.version       = Legion::Extensions::CognitiveChrysalis::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Chrysalis'
  spec.description   = 'Metamorphic identity transformation for LegionIO agents — structured dissolution and reformation cycles'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-chrysalis'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-chrysalis'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-chrysalis'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-chrysalis'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-chrysalis/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
