# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "leeloo/version"

Gem::Specification.new do |spec|
  spec.name          = "leeloo"
  spec.version       = Leeloo::VERSION
  spec.authors       = ["sylvek"]
  spec.email         = ["smaucourt@gmail.com"]

  spec.summary       = Leeloo::DESCRIPTION
  spec.description   = Leeloo::DESCRIPTION
  spec.homepage      = "https://github.com/sylvek/leeloo"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0").select {|f| f.match(%r{^(lib|exe)/}) }

  spec.bindir        = "exe"
  spec.executables   = %w[leeloo]
  spec.require_paths = ["lib"]

  spec.add_dependency "commander", "~> 4.4"
  spec.add_dependency "gpgme", "~> 2.0"
  spec.add_dependency "git", "~> 1.5"
  spec.add_dependency "tty-table", "~> 0.10"
  spec.add_dependency "tty-tree", "~> 0.3"
  spec.add_dependency "clipboard", "~> 1.3"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
