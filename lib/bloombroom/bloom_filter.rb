require 'ffi/bloombroom/hash/fnv'
require 'bloombroom/bit_field'
require 'bloombroom/bloom_helper'

module Bloombroom

  # BloomFilter false positive probability rule of thumb: see http://www.igvita.com/2008/12/27/scalable-datasets-bloom-filters-in-ruby/
  # a Bloom filter with a 1% error rate and an optimal value for k only needs 9.6 bits per key, and each time we add 4.8 bits 
  # per element we decrease the error rate by ten times. 
  #
  # 10000 elements, 1% error rate: m = 10000 * 10 bits -> 12k of memory, k = 0.7 * (10000 * 10 bits / 10000) = 7 hash functions
  # 10000 elements, 0.1% error rate: m = 10000 * 15 bits -> 18k of memory, k = 0.7 * (10000 * 15 bits / 10000) = 11 hash functions
  #
  # Bloombroom::BloomHelper.find_m_k can be used to compute optimal m & k values for a required capacity and error rate.
  class BloomFilter

    attr_reader :m, :k, :bits, :size

    # @param m [Fixnum] filter size in bits
    # @param k [Fixnum] number of hashing functions
    def initialize(m, k)
      @bits = BitField.new(m)
      @m = m
      @k = k
      @size = 0
    end
    
    def add(key)
      BloomHelper.multi_hash(key, @k).each{|position| @bits.set(position % @m)}
      @size += 1
    end
    
    def include?(key)
      BloomHelper.multi_hash(key, @k).each{|position| return false unless @bits.include?(position % @m)}
      true
    end
    
  end
end