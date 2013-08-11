require 'bloombroom/hash/ffi_fnv'
require 'bloombroom/bits/bit_bucket_field'
require 'bloombroom/filter/bloom_helper'
require 'thread'

module Bloombroom

  # CountingBloomFilter is a counting bloom filter. This is a retrofit of the ContinuousBloomFilter to remove ttl
  # and instead implement a counter value for the key.
  class CountingBloomFilter

    attr_reader :m, :k, :b, :roll_over, :bits_per_bucket, :buckets

    # Set to 16 as default. For simple exists or not you should pass b=2 to #initialize
    DEFAULT_MAX_COUNTER = 16

    # @param m [Fixnum] total filter size in number of buckets. optimal m can be computed using BloomHelper.find_m_k
    # @param k [Fixnum] number of hashing functions. optimal k can be computed using BloomHelper.find_m_k
    # @param b [Fixnum] the target decimal value to size the counter value bit bucket. default is 4 bits (16 decimal)
    # @param r [Fixnum] whether to allow the counter to roll over or force max at [b - 1] and min at 0 (false & default)
    def initialize(m, k, r = false, b = DEFAULT_MAX_COUNTER)
      b                = b >= 2 ? b : 2
      @m               = m
      @k               = k
      @b               = b
      @roll_over       = r
      @bits_per_bucket = Math.log2(b).ceil
      @buckets         = BitBucketField.new(@bits_per_bucket, m)
    end

    # @param key [String] the key to add in the filter
    # @param value [Integer] an optional value to add (defaults to 1)
    # @return [Integer] find_majority(bit_counts)
    def increment(key, value = 1)
      BloomHelper.multi_hash(key, @k).each do |position|
        if !@roll_over && (@buckets[position % @m] + value) >= (@b - 1)
          # Value would be greater or equal to maximum, so we set to maximum
          @buckets[position % @m] = (@b - 1)
        else
          # Value would be less than maximum so we just add and/or @roll_over == true
          @buckets[position % @m] = @buckets[position % @m] + value
        end
      end
      count(key)
    end

    alias_method :add, :increment

    # @param key [String] the key to add in the filter
    # @param value [Integer] an optional value to subtract (defaults to 1)
    # @return [Integer] find_majority(bit_counts)
    def decrement(key, value = 1)
      BloomHelper.multi_hash(key, @k).each do |position|
        if !@roll_over && (@buckets[position % @m] - value) <= 0
          # Value would be less or equal to 0, so we set to 0
          @buckets[position % @m] = 0
        else
          # Value would be greater than 0 so we just decrement and/or @roll_over == true
          @buckets[position % @m] = @buckets[position % @m] - value
        end
      end
      count(key)
    end

    alias_method :subtract, :decrement

    # @param key [String] the key to set the value for in the filter
    # @param value [Integer] value to set
    # @return [Integer] find_majority(bit_counts)
    def set(key, value)
      value = 0 if value < 0
      value = (@b - 1) if value > (@b - 1)
      BloomHelper.multi_hash(key, @k).each do |position|
        @buckets[position % @m] = value
      end
      count(key)
    end

    # @param key [String] the key to reset in the filter
    # @return [Integer] 0
    def reset(key)
      #
      BloomHelper.multi_hash(key, @k).each do |position|
        @buckets[position % @m] = 0
      end
      count(key)
    end

    alias_method :clear, :reset

    # @param key [String] test for the inclusion if key in the filter
    # @return [Boolean] true if given key is present in the filter with a value > 0. false positive are possible and dependant on the m and k filter parameters.
    def include?(key)
      count(key) > 0
    end

    alias_method :[], :include?

    # @param key [String] returns the counter for the key in the filter
    # @return [Integer] find_majority(bit_counts)
    def count(key)
      bit_counts = BloomHelper.multi_hash(key, @k).map { |position| @buckets[position % @m] }
      find_majority(bit_counts)
    end

    alias_method :size, :count

    private

    # @param bit_counts [Array] an Array of returned bit count values
    def find_majority(bit_counts)
      # Pivot the counters into key(counter value) => value(number of times it appears)
      pivoted_bit_counts = bit_counts.inject(Hash.new(0)) { |total, e| total[e] += 1; total }
      # Select the highest appearing count
      majority           = pivoted_bit_counts.max_by { |h| h.last }
      # Return the counter value
      majority.first
    end

  end
end