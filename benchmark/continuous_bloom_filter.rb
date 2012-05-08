$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require "benchmark"
require "digest/sha1"
require 'bloombroom/filter/continuous_bloom_filter'
require 'bloombroom/filter/bloom_helper'

KEYS_COUNT = 150000
TEST_M_K = [0.1, 0.01, 0.001].map{|error| Bloombroom::BloomHelper.find_m_k(KEYS_COUNT, error)}

keys = KEYS_COUNT.times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}
slots = 10.times.map{|i| (KEYS_COUNT / 3).times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}} 

if !!(defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby')
  puts("warming JVM...")
  bf = Bloombroom::SteamingBloomFilter.new(Bloombroom::BloomHelper.find_m_k(KEYS_COUNT, 0.001))
  keys.each{|key| bf.add(key)}
end

puts("\nbenchmarking without expiration for #{keys.size} keys")

reports = []
Benchmark.bm(70) do |x|
  TEST_M_K.each do |m, k|
    bf = Bloombroom::ContinuousBloomFilter.new(m, k, 0)
    adds = x.report("ContinuousBloomFilter m=#{m}, k=#{k} add") {keys.each{|key| bf.add(key)}}
    includes = x.report("ContinuousBloomFilter m=#{m}, k=#{k} include?") {keys.each{|key| bf.include?(key)}}
    reports << {:m => m, :k => k, :adds => adds, :includes => includes}
  end
end

puts("\n")

reports.each do |report|
  puts("ContinuousBloomFilter m=#{report[:m]}, k=#{report[:k]} add          #{"%10.0f" % (keys.size / report[:adds].real)} ops/s")
  puts("ContinuousBloomFilter m=#{report[:m]}, k=#{report[:k]} include?     #{"%10.0f" % (keys.size / report[:includes].real)} ops/s")
end

puts("\nbenchmarking with expiration for #{slots.map(&:size).reduce(&:+)} keys")

reports = []
Benchmark.bm(70) do |x|
  TEST_M_K.each do |m, k|
    bf = Bloombroom::ContinuousBloomFilter.new(m, k, 0)
    addincludes = x.report("ContinuousBloomFilter m=#{m}, k=#{k} add+include") do
      slots.each do |slot|
        slot.each{|key| bf.add(key)}
        slot.each{|key| bf.include?(key)}
        bf.inc_time_slot
      end
    end

    reports << {:m => m, :k => k, :addincludes => addincludes}
  end
end

puts("\n")

reports.each do |report|
  puts("ContinuousBloomFilter m=#{report[:m]}, k=#{report[:k]} add+include #{"%10.0f" % (slots.map(&:size).reduce(&:+) / report[:addincludes].real)} ops/s")
end
