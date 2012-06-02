# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "circuit/version"

Gem::Specification.new do |s|
  s.name        = "circuit"
  s.version     = Circuit::VERSION
  s.authors     = ["Blake Chambers", "Travis D. Warlick, Jr.", "Maxmedia"]
  s.email       = ["chambb1@gmail.com", "twarlick@gmail.com"]
  s.homepage    = "https://github.com/maxmedia/circuit"
  s.summary     = %q{Dynamic rack routing platform}
  s.description = %q{Dynamic rack routing platform}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activesupport",  "~> 3.1"
  s.add_runtime_dependency "activemodel",    "~> 3.1"
  # see Gemfile for development dependencies
end