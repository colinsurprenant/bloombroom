$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require "benchmark"
require "digest/sha1"
require 'bloombroom/streaming_bloom_filter'
require 'bloombroom/bloom_filter'
require 'bloombroom/bloom_helper'

module Bloombroom

  KEYS_PER_SLOT = 20000
  SLOTS_PER_FILTER = 3
  KEY_VALUE_RANGE = 100000000

  slots = 32.times.map do
    add = {}
    KEYS_PER_SLOT.times.each{|i| add["#{i}#{Digest::SHA1.hexdigest(rand(KEY_VALUE_RANGE).to_s)}"] = true}

    free = []
    while free.size < add.size
      key = "#{Digest::SHA1.hexdigest(rand(KEY_VALUE_RANGE).to_s)}"
      free << key unless add.has_key?(key)
    end
    
    [add.keys, free]
  end

  # puts(slots.map{|slot| slot.first.size}.inspect)
  # puts(slots.map{|slot| slot.last.size}.inspect)

  capacity = KEYS_PER_SLOT * SLOTS_PER_FILTER
  error = 0.001 # 0.001 == 0.1%

  m, k = BloomHelper.find_m_k(capacity, error)
  puts("\nStreaming BloomFilter with capacity=#{capacity}, error=#{error}(#{error * 100}%) -> m=#{m}, k=#{k}")
  bf = StreamingBloomFilter.new(m, k, 0)

  n = 0
  t = Benchmark.realtime do
    slots.each do |slot|
      slot.first.each{|key| bf.add(key); n += 1}
      false_positives = slot.last.map{|key| bf.include?(key) ? 1 : 0}.reduce(:+)
      # true_positives = slot.first.map{|key| bf.include?(key) ? 1 : 0}.reduce(:+)
      # "true positives = #{true_positives}/#{slot.first.size}, #{"%.3f" % ((true_positives * 100) / Float(slot.first.size))}%",
      puts("false positives=#{false_positives}/#{slot.last.size} (#{"%.3f" % ((false_positives * 100) / Float(slot.last.size))})%, n=#{n}")
      bf.inc_time_slot
    end
  end
  puts("Streaming BloomFilter #{n} adds + #{n} tests in #{"%.2f" % t}s, operations rate=#{"%.2f" % ((2 * n) / t)}/s")


  puts("\nBloomFilter with capacity=#{capacity}, error=#{error}(#{error * 100}%) -> m=#{m}, k=#{k}")
  bf = BloomFilter.new(m, k)

  n = 0
  t = Benchmark.realtime do
    slots[0, SLOTS_PER_FILTER + 2].each do |slot|
      slot.first.each{|key| bf.add(key); n += 1}
      false_positives = slot.last.map{|key| bf.include?(key) ? 1 : 0}.reduce(:+)
      # true_positives = slot.first.map{|key| bf.include?(key) ? 1 : 0}.reduce(:+)
      # "true positives = #{true_positives}/#{slot.first.size}, #{"%.3f" % ((true_positives * 100) / Float(slot.first.size))}%,"
      puts("false positives=#{false_positives}/#{slot.last.size} (#{"%.3f" % ((false_positives * 100) / Float(slot.last.size))})%, n=#{n}")
    end
  end
  puts("BloomFilter #{n} adds + #{n} tests in #{"%.2f" % t}s, operations rate=#{"%.2f" % ((2 * n) / t)}/s")

end