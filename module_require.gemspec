# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "module_require/version"

Gem::Specification.new do |spec|
  spec.name          = "module_require"
  spec.version       = ModuleRequire::VERSION
  spec.authors       = ["Stephen Best"]
  spec.email         = ["bestie@gmail.com"]

  spec.summary       = %q{Language extention that allows code loading into scoped modules}
  spec.homepage      = "https://github.com/bestie/module_require"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "0.10.1"
  spec.add_development_dependency "rspec"
end
