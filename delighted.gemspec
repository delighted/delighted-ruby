lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'delighted/version'

Gem::Specification.new do |spec|
  spec.name          = "delighted"
  spec.version       = Delighted::VERSION
  spec.authors       = ["Mark Dodwell"]
  spec.email         = ["mark@madeofcode.com"]
  spec.description   = "Delighted API client for Ruby."
  spec.summary       = "Delighted is the easiest and most beautiful way to measure customer happiness. Are your customers delighted?"
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
