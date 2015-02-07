# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bloombroom/version"

Gem::Specification.new do |s|
  s.name        = "bloombroom"
  s.version     = Bloombroom::VERSION
  s.authors     = ["Colin Surprenant"]
  s.email       = ["colin.surprenant@gmail.com"]
  s.homepage    = "https://github.com/colinsurprenant/bloombroom"
  s.summary     = "bloom filters for bounded and unbounded (streaming) data, fast C/FFI FNV hashing and bit fields"
  s.description = "bloombroom has two bloom filter implementations, a standard filter for bounded key space \
                   and a continuous filter for unbounded keys (stream). also contains fast C/FFI FNV hashing and fast bit field and \
                   bit bucket field (multi bits)."

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.extensions    = ["ffi/bloombroom/hash/Rakefile"]

  s.has_rdoc = false
  s.license = 'Apache 2.0'
  
  s.add_dependency "ffi", ">= 1.0.0"
  s.add_dependency "ffi-compiler"
  s.add_development_dependency "rspec", "~> 2.8"
end
