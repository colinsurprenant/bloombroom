require 'ffi/bloombroom/hash/fnv'

module Bloombroom

  class BloomHelper

    # compute optimal m and k for a given capacity and error rate
    # @param capacity [Fixnum] number of expected keys
    # @param error [Float] error rate (0.0 < error < 1.0). Ex: 1% == 0.01, 0.1% == 0.001, ...
    def self.find_m_k(capacity, error)
      # thanks to http://www.siaris.net/index.cgi/Programming/LanguageBits/Ruby/BloomFilter.rdoc
      m = (capacity * Math.log(error) / Math.log(1.0 / 2 ** Math.log(2))).ceil
      k = (Math.log(2) * m / capacity).round
      [m, k]
    end
    
    # produce k hash values for key
    # @param key [String] key to hash
    # @param k [Fixnum] number of hash functions
    def self.multi_hash(key, k)
      # simulate n hash functions by having just two hash functions
      # see http://citeseer.ist.psu.edu/viewdoc/download?doi=10.1.1.152.579&rep=rep1&type=pdf
      # see http://willwhim.wordpress.com/2011/09/03/producing-n-hash-functions-by-hashing-only-once/
      #
      # fake two hash functions by using the upper/lower 32 bits of a 64 bits FNV1a hash

      h = Bloombroom::FNVFFI.fnv1a_64(key)
      a = (h & 0xFFFFFFFF00000000) >> 32
      b = h & 0xFFFFFFFF

      Array.new(k) {|i| (a + b * (i + 1))}
    end

  end
end
