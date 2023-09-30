# -*- encoding: utf-8 -*-

Gem::Specification.new do |spec|
  spec.name          = "motion-turbo"
  spec.version       = "0.1.1"
  spec.authors       = ["Andrew Havens", "Petrik de Heus"]
  spec.email         = ["email@andrewhavens.com"]
  spec.description   = %q{Turbo for RubyMotion apps}
  spec.summary       = %q{Turbo for RubyMotion apps}
  spec.homepage      = "https://github.com/rubymotion-community/motion-turbo"
  spec.license       = "MIT"

  files = []
  files << 'README.md'
  files.concat(Dir.glob('lib/**/*.rb'))
  spec.files         = files
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "motion-lager"

  spec.add_development_dependency "rake"
end
