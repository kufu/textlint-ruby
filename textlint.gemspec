# frozen_string_literal: true

require_relative 'lib/textlint/version'

Gem::Specification.new do |spec|
  spec.name          = 'textlint'
  spec.version       = Textlint::VERSION
  spec.authors       = ['alpaca-tc']
  spec.email         = ['alpaca-tc@alpaca.tc']

  spec.summary       = 'ruby AST parser for textlint'
  spec.description   = ''
  spec.homepage      = 'https://github.com/alpaca-tc/textlint-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/alpaca-tc/textlint-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/alpaca-tc/textlint-ruby/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
