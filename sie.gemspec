# coding: utf-8
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sie/version"

Gem::Specification.new do |spec|
  spec.name          = "sie"
  spec.version       = Sie::VERSION
  spec.authors       = [ "Barsoom AB" ]
  spec.email         = [ "all@barsoom.se" ]
  spec.description   = %q{SIE parser and generator}
  spec.summary       = %q{Parses and generates SIE files (http://sie.se/)}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.metadata      = { "rubygems_mfa_required" => "true" }

  spec.files         = Dir["lib/**/*.rb", "README.md"]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "activesupport"
  spec.add_dependency "attr_extras"
end
