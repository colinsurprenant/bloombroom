$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require "benchmark"
require "digest/sha1"
require "bloombroom"

module Bloombroom

  KEYS_PER_SLOT = 20000
  SLOTS_PER_FILTER = 3
  KEY_VALUE_RANGE = 100000000

  puts("\ngenerating lots of random keys")
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
  puts("\nContinuous BloomFilter with capacity=#{capacity}, error=#{error}(#{error * 100}%) -> m=#{m}, k=#{k}")
  bf = ContinuousBloomFilter.new(m, k, 0)

  t = Benchmark.realtime do
    slots.each do |slot|
      slot.first.each{|key| bf.add(key)}
      false_positives = 0
      slot.last.each{|key| false_positives += 1 if bf.include?(key)}
      puts("added #{slot.first.size} keys, tested #{slot.last.size} keys, FPs=#{false_positives}/#{slot.last.size} (#{"%.3f" % ((false_positives * 100) / Float(slot.last.size))})%")
      bf.inc_time_slot
    end
  end
  n = slots.size * KEYS_PER_SLOT 
  puts("Continuous BloomFilter #{n} adds + #{n} tests in #{"%.2f" % t}s, #{"%2.0f" % ((2 * n) / t)} ops/s")


  puts("\nBloomFilter with capacity=#{capacity}, error=#{error}(#{error * 100}%) -> m=#{m}, k=#{k}")
  bf = BloomFilter.new(m, k)

  t = Benchmark.realtime do
    slots[0, SLOTS_PER_FILTER + 3].each do |slot|
      slot.first.each{|key| bf.add(key); n += 1}
      false_positives = 0
      slot.last.each{|key| false_positives += 1 if bf.include?(key)}
      puts("added #{slot.first.size} keys, tested #{slot.last.size} keys, FPs=#{false_positives}/#{slot.last.size} (#{"%.3f" % ((false_positives * 100) / Float(slot.last.size))})%")
    end
  end
  n = (SLOTS_PER_FILTER + 3) * KEYS_PER_SLOT 
  puts("BloomFilter #{n} adds + #{n} tests in #{"%.2f" % t}s, #{"%2.0f" % ((2 * n) / t)} ops/s")

end