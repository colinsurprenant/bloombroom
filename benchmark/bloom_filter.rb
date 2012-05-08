$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require "benchmark"
require "digest/sha1"
require 'bloombroom/filter/bloom_filter'
require 'bloombroom/filter/bloom_helper'

KEYS_COUNT = 150000
TEST_M_K = [0.1, 0.01, 0.001].map{|error| Bloombroom::BloomHelper.find_m_k(KEYS_COUNT, error)}

keys = KEYS_COUNT.times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}

if !!(defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby')
  puts("warming JVM...")
  bf = Bloombroom::BloomFilter.new(KEYS_COUNT, 7)
  keys.each{|key| bf.add(key)}
end

puts("benchmarking for #{keys.size} keys")

reports = []
Benchmark.bm(40) do |x|
  TEST_M_K.each do |m, k|
    bf = Bloombroom::BloomFilter.new(m, k)
    adds = x.report("BloomFilter m=#{m}, k=#{k} add") {keys.each{|key| bf.add(key)}}
    includes = x.report("BloomFilter m=#{m}, k=#{k} include?") {keys.each{|key| bf.include?(key)}}
    reports << {:m => m, :k => k, :adds => adds, :includes => includes}
  end
end

puts("\n")

reports.each do |report|
  puts("BloomFilter m=#{report[:m]}, k=#{report[:k]} add        #{"%10.0f" % (keys.size / report[:adds].real)} ops/s")
  puts("BloomFilter m=#{report[:m]}, k=#{report[:k]} include?   #{"%10.0f" % (keys.size / report[:includes].real)} ops/s")
end

