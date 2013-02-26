require 'ffi'
require 'ffi-compiler/loader'

module Bloombroom
  class FNVFFI
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('ffi_fnv')
  end
end

require "bloombroom/version"
require "bloombroom/bits/bit_field"
require "bloombroom/bits/bit_bucket_field"
require "bloombroom/filter/bloom_helper"
require "bloombroom/filter/bloom_filter"
require "bloombroom/filter/continuous_bloom_filter"
require "bloombroom/hash/fnv_a"
require "bloombroom/hash/fnv_b"
require "bloombroom/hash/ffi_fnv"
require "bloombroom/hash/cext_fnv" unless RUBY_PLATFORM =~ /java/
