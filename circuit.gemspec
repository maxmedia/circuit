# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "circuit/version"

Gem::Specification.new do |s|
  s.name        = "circuit"
  s.version     = Circuit::VERSION
  s.license     = 'MIT'
  s.authors     = ["Maxmedia", "Blake Chambers", "Travis D. Warlick, Jr."]
  s.email       = ["it@maxmedia.com", "chambb1@gmail.com", "twarlick@gmail.com"]
  s.homepage    = "http://github.com/maxmedia/circuit"
  s.summary     = %q{Dynamic (backend-driven) request routing for Rack}
  s.description = File.read("description.md").gsub(/\s*\n+\s*/, " ")

  s.files                 = Dir[ *%w[lib/**/*.rb vendor/**/*.rb config.ru *file description.md] ].tap do |a|
                              a.delete_if {|fn| File.basename(fn) =~ /^\./}
                            end
  s.test_files            = Dir[ *%w[spec/**/*.rb] ]
  s.extra_rdoc_files      = Dir[ *%w[README.md LICENSE docs/*.md] ]
  s.rdoc_options.concat   ["--main",  "README.md"]
  s.require_paths         = ["lib"]

  s.required_ruby_version = ">= 1.8.7"

  s.add_runtime_dependency "rack",           "~> 1.3"
  s.add_runtime_dependency "activesupport",  "~> 3.1"
  s.add_runtime_dependency "activemodel",    "~> 3.1"
  s.add_runtime_dependency "dionysus",       "~> 2.2.0.0.pre"
  # see Gemfile for development dependencies
end
