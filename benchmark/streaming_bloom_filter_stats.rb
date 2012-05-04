$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require "benchmark"
require "digest/sha1"
require 'bloombroom/streaming_bloom_filter'
require 'bloombroom/bloom_filter'
require 'bloombroom/bloom_helper'

module Bloombroom

  KEYS_PER_SLOT = 10000
  KEY_VALUE_RANGE = 100000000

  slots = 32.times.map do
    add = {}
    KEYS_PER_SLOT.times.each{|i| add["#{rand(KEY_VALUE_RANGE)}"] = true}

    free = []
    while free.size < add.size
      key = "#{rand(KEY_VALUE_RANGE)}"
      free << key unless add.has_key?(key)
    end
    
    [add.keys, free]
  end

  puts(slots.map{|slot| slot.first.size}.inspect)
  puts(slots.map{|slot| slot.last.size}.inspect)

  m, k = BloomHelper.find_m_k(KEYS_PER_SLOT * 3, 0.1)
  puts("Streaming BloomFilter with m=#{m}, k=#{k}")
  bf = StreamingBloomFilter.new(m, k, 0)

  slots.each do |slot|
    slot.first.each{|key| bf.add(key)}
    true_positives = slot.first.map{|key| bf.include?(key) ? 1 : 0}.reduce(:+)
    false_positives = slot.last.map{|key| bf.include?(key) ? 1 : 0}.reduce(:+)
    puts("false positives = #{false_positives}/#{slot.last.size}, #{"%.3f" % ((false_positives * 100) / Float(slot.last.size))}%, true positives = #{true_positives}/#{slot.first.size}, #{"%.3f" % ((true_positives * 100) / Float(slot.first.size))}%")
    bf.inc_time_slot
  end


  puts("BloomFilter with m=#{m}, k=#{k}")
  bf = BloomFilter.new(m, k)

  slots.each do |slot|
    slot.first.each{|key| bf.add(key)}
    true_positives = slot.first.map{|key| bf.include?(key) ? 1 : 0}.reduce(:+)
    false_positives = slot.last.map{|key| bf.include?(key) ? 1 : 0}.reduce(:+)
    puts("false positives = #{false_positives}/#{slot.last.size}, #{"%.3f" % ((false_positives * 100) / Float(slot.last.size))}%, true positives = #{true_positives}/#{slot.first.size}, #{"%.3f" % ((true_positives * 100) / Float(slot.first.size))}%")
  end
end