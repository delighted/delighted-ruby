lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'delighted/version'

Gem::Specification.new do |spec|
  spec.name          = "delighted"
  spec.version       = Delighted::VERSION
  spec.authors       = ["Mark Dodwell"]
  spec.email         = ["mark@delighted.com"]
  spec.description   = "Delighted API Ruby Client."
  spec.summary       = "Delighted is the fastest and easiest way to gather actionable feedback from your customers."
  spec.homepage      = "https://github.com/delighted/delighted-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ["lib"]

  spec.add_dependency "multi_json"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
end
