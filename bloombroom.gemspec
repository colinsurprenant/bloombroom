# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bloombroom/version"

Gem::Specification.new do |s|
  s.name        = "bloombroom"
  s.version     = Bloombroom::VERSION
  s.authors     = ["Colin Surprenant"]
  s.email       = ["colin.surprenant@gmail.com"]
  s.homepage    = "https://github/colinsurprenant/bloombroom"
  s.summary     = "bloom filters for bounded and unbounded (streaming) data, FNV hashing and bit fields"
  s.description = "bloombroom has two bloom filter implementations, a standard filter for bounded key space \
                   and a continuous filter for unbounded keys (stream). also contains fast bit field and \
                   bit bucket field (multi bits), native/C-ext/FFI FNV hashing and benchmarks for all these."

  s.rubyforge_project = "bloombroom"

  s.files         = Dir.glob("{lib/**/*.rb}") + Dir.glob("{ext/**/*.(c|rb)}") + %w(README.md CHANGELOG.md LICENSE.md)
  s.test_files    = Dir.glob("{spec/**/*.rb}")
  s.require_paths = ["lib"]
  s.extensions    = ["ext/bloombroom/hash/cext/extconf.rb", "ext/bloombroom/hash/ffi/extconf.rb"]

  s.add_development_dependency "rspec", ["~> 2.8.0"]
  
  s.add_runtime_dependency "ffi"
end
