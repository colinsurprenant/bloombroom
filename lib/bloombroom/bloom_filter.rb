require 'ffi/bloombroom/hash/fnv'
require 'bloombroom/bit_field'

module Bloombroom

  # BloomFilter false positive probability rule of thumb: see http://www.igvita.com/2008/12/27/scalable-datasets-bloom-filters-in-ruby/
  # a Bloom filter with a 1% error rate and an optimal value for k only needs 9.6 bits per key, and each time we add 4.8 bits 
  # per element we decrease the error rate by ten times. 
  #
  # 10000 elements, 1% error rate: m = 10000 * 10 bits -> 12k of memory, k = 0.7 * (10000 * 10 bits / 10000) = 7 hash functions
  # 10000 elements, 0.1% error rate: m = 10000 * 15 bits -> 18k of memory, k = 0.7 * (10000 * 15 bits / 10000) = 11 hash functions
  class BloomFilter

    attr_reader :bits

    # @param m [Fixnum] filter size in bits
    # @param k [Fixnum] number of hashing functions
    def initialize(m, k)
      @bits = BitField.new(m)
      @m = m
      @k = k
    end
    
    # produce k hash values for key
    def multi_hash(key)
      # simulate n hash functions by having just two hash functions
      # see http://citeseer.ist.psu.edu/viewdoc/download?doi=10.1.1.152.579&rep=rep1&type=pdf
      # see http://willwhim.wordpress.com/2011/09/03/producing-n-hash-functions-by-hashing-only-once/
      #
      # fake two hash functions by using the upper/lower 32 bits of a 64 bits FNV1a hash

      h = Bloombroom::FNVFFI.fnv1a_64(key)
      a = (h & 0xFFFFFFFF00000000) >> 32
      b = h & 0xFFFFFFFF

      Array.new(@k) {|i| (a + b * (i + 1))}
    end
    
    def add(key)
      multi_hash(key).each{|position| @bits.set(position % @m)}
    end
    
    def include?(key)
      multi_hash(key).each{|position| return false unless @bits.include?(position % @m)}
      true
    end
    
  end
end