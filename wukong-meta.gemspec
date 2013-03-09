# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wukong-meta/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'wukong-meta'
  gem.homepage    = 'https://github.com/infochimps-labs/wukong-meta'
  gem.licenses    = ["Apache 2.0"]
  gem.email       = 'coders@infochimps.com'
  gem.authors     = ['Infochimps', 'Philip (flip) Kromer', 'Travis Dempsey', 'Dhruv Bansal']
  gem.version     = Wukong::Meta::VERSION

  gem.summary     = 'Introspects on deploy packs'
  gem.description = <<-EOF
Wukong-Meta is a tool for extracting various kinds of metadata about a
deploy pack.  It introspects on the deploy pack's structure and
contents and produces summary data about what processors, dataflows,
models, jobs, &c. are available.
EOF

  gem.files         = `git ls-files`.split("\n")
  gem.executables   = ['wu-show']
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = ['lib']

  gem.add_dependency('wukong-deploy',      '0.1.1')
  gem.add_dependency('formatador')
end
