# -*- encoding: utf-8 -*-
VERSION = "1.0"

Gem::Specification.new do |spec|
  spec.name          = "motion-turbolinks"
  spec.version       = VERSION
  spec.authors       = ["Andrew Havens"]
  spec.email         = ["email@andrewhavens.com"]
  spec.description   = %q{Turbolinks for RubyMotion apps}
  spec.summary       = %q{Turbolinks for RubyMotion apps}
  spec.homepage      = "https://github.com/andrewhavens/motion-turbolinks"
  spec.license       = "MIT"

  files = []
  files << 'README.md'
  files.concat(Dir.glob('lib/**/*.rb'))
  spec.files         = files
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.executables   << "turbolinks_demo_server"

  spec.add_development_dependency "rake"
end
