# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'craigslist_scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "craigslist_scraper"
  spec.version       = CraigslistScraper::VERSION
  spec.authors       = ["mark nery"]
  spec.email         = ["marknery@gmail.com"]
  spec.description   = %q{a gem that scrapes craigslist data}
  spec.summary       = %q{a gem that scrapes craigslist data}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
