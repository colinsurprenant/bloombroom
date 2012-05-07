require 'ffi/bloombroom/hash/fnv'
require 'bloombroom/bit_bucket_field'
require 'bloombroom/bloom_helper'
require 'thread'

module Bloombroom

  # StreamingBloomFilter is a bloom filter which expires keys over a given period of time. It is useful
  # for unbounded streams of keys. The expected capacity of the bloom filter for the desired validity period
  # must be known or estimated. For a given capacity and error rate, BloomHelper.find_m_k can be used to compute
  # optimal m & k values. 
  #
  # 4 bits per key (instead of 1 bit in a normal bloom filter) are used for keeping track of the keys ttl. 
  # the internal timer resolution is set to half of the ttl. using 4 bits gives us 15 usable time slots
  # (slot 0 is for the unset state). basically the internal time bookeeping is similar to a ring buffer
  # where the first timer tick will be time slot=1, slot=2, .. slot=15, slot=1 and so on. The total time of our internal 
  # clock will thus be 15 * (ttl / 2). We keep track of ttl by writing the current time slot in the key k buckets
  # when first inserted in the filter. when doing a key lookup if any of the bucket contain the 0 value the key
  # is not found. if the interval betweem the current time slot and any of the k buckets value is greater 
  # than 2 (timer resolution) we know this key is expired and we reset the expired buckets to 0.
  class StreamingBloomFilter

    attr_reader :m, :k, :ttl, :buckets

    RESOLUTION_DIVISOR = 2
    BITS_PER_BUCKET = 4

    # @param m [Fixnum] total filter size in number of buckets. optimal m can be computed using BloomHelper.find_m_k
    # @param k [Fixnum] number of hashing functions. optimal k can be computed using BloomHelper.find_m_k
    # @param ttl [Fixnum] key time to live in seconds (validity period)
    def initialize(m, k, ttl)
      @buckets = BitBucketField.new(BITS_PER_BUCKET, m)
      @m = m
      @k = k
      @ttl = ttl

      # time management
      @increment_period = @ttl / RESOLUTION_DIVISOR
      @current_slot = 1
      @max_slot = (2 ** BITS_PER_BUCKET) - 1 # ex. with 4 bits -> we want range 1..15
      @lock = Mutex.new
    end
    
    # @param key [String] the key to add in the filter
    def add(key)
      current_slot = @lock.synchronize{@current_slot}
      BloomHelper.multi_hash(key, @k).each{|position| @buckets[position % @m] = current_slot}
    end
    
    # @param key [String] test for the inclusion if key in the filter
    # @return [Boolean] true if given key is present in the filter. false positive are possible and dependant on the  m and k filter parameters.
    def include?(key)
      current_slot = @lock.synchronize{@current_slot}
      expired = false

      BloomHelper.multi_hash(key, @k).each do |position| 
        start_slot = @buckets[position % @m]
        if start_slot == 0
          expired = true
        elsif elapsed(start_slot, current_slot) > RESOLUTION_DIVISOR
          expired = true
          @buckets[position % @m] = 0
        end
      end
      !expired
    end

    # start the internal timer thread for managing ttls. must be explicitely called 
    def start_timer
      @timer ||= detach_timer
    end

    # advance internal time slot. this is exposed primarily for spec'ing purposes.
    # normally this is automatically called by the internal timer thread but if not 
    # using the internal timer thread it can be called explicitly when doing your
    # own time management.
    def inc_time_slot
      # ex. with 4 bits -> we want range 1..15, 
      @lock.synchronize{@current_slot = (@current_slot % @max_slot) + 1}
    end

    private

    def current_slot
      @lock.synchronize{@current_slot}
    end

    def elapsed(start_slot, current_slot)
      # ring buffer style
      current_slot >= start_slot ? current_slot - start_slot : (current_slot + @max_slot) - start_slot
    end

    def detach_timer
      Thread.new do
        Thread.current.abort_on_exception = true

        loop do
          sleep(@increment_period)
          inc_time_slot
        end 
      end
    end

  end
end