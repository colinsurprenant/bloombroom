require 'ffi/bloombroom/hash/fnv'
require 'bloombroom/bit_bucket_field'
require 'bloombroom/bloom_helper'
require 'thread'

module Bloombroom

  class StreamingBloomFilter

    attr_reader :m, :k, :ttl, :buckets

    RESOLUTION_DIVISOR = 2
    BITS_PER_BUCKET = 4

    # @param m [Fixnum] filter size in bits
    # @param k [Fixnum] number of hashing functions
    # @param ttl [Fixnum] key time to live in seconds
    def initialize(m, k, ttl)
      @buckets = BitBucketField.new(BITS_PER_BUCKET, m)
      @m = m
      @k = k
      @ttl = ttl

      # time management
      @increment_period = @ttl / RESOLUTION_DIVISOR
      @current_slot = 1
      @ttl_slot_count = RESOLUTION_DIVISOR + 1
      @max_slot = (2 ** BITS_PER_BUCKET) - 1 # ex. with 4 bits -> we want range 1..15
      @lock = Mutex.new
    end
    
    def add(key)
      current_slot = @lock.synchronize{@current_slot}
      BloomHelper.multi_hash(key, @k).each{|position| @buckets[position % @m] = current_slot}
    end
    
    def include?(key)
      current_slot = @lock.synchronize{@current_slot}
      expired = false

      BloomHelper.multi_hash(key, @k).each do |position| 
        start_slot = @buckets[position % @m]
        if start_slot == 0
          expired = true
        elsif elapsed(start_slot, current_slot) >= @ttl_slot_count
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

    # advance internal time slot. this is exposed primarily for spec'ing purposes
    def inc_time_slot
      # ex. with 4 bits -> we want range 1..15, 
      @lock.synchronize{@current_slot = (@current_slot % @max_slot) + 1}
    end

    def current_slot
      @lock.synchronize{@current_slot}
    end

    private

    def elapsed(start_slot, current_slot)
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