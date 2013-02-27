require 'bundler/setup'
require "benchmark"
require "digest/sha1"
require "bloombroom"

KEYS_COUNT = 150000
ERRORS = [0.01, 0.001, 0.0001]
TEST_M_K = ERRORS.map{|error| Bloombroom::BloomHelper.find_m_k(KEYS_COUNT, error)}

keys = KEYS_COUNT.times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}
slots = 10.times.map{|i| (KEYS_COUNT / 3).times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}} 

if !!(defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby')
  puts("warming JVM...")
  bf = Bloombroom::ContinuousBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(KEYS_COUNT, 0.001), 0)
  keys.each{|key| bf.add(key)}
end

puts("benchmarking WITHOUT expiration for #{keys.size} keys with #{ERRORS.map{|e| "#{e * 100}%"}.join(", ")} error rates")

reports = []
Benchmark.bm(53) do |x|
  TEST_M_K.each do |m, k|
    bf = Bloombroom::ContinuousBloomFilter.new(m, k, 0)
    adds = x.report("ContinuousBloomFilter m=#{"%07.0f" % m}, k=#{"%02.0f" % k} add") {keys.each{|key| bf.add(key)}}
    includes = x.report("ContinuousBloomFilter m=#{"%07.0f" % m}, k=#{"%02.0f" % k} include?") {keys.each{|key| bf.include?(key)}}
    reports << {:m => m, :k => k, :adds => adds, :includes => includes}
  end
end

puts("\n")

reports.each do |report|
  puts("ContinuousBloomFilter m=#{"%07.0f" % report[:m]}, k=#{"%02.0f" % report[:k]} add          #{"%10.0f" % (keys.size / report[:adds].real)} ops/s")
  puts("ContinuousBloomFilter m=#{"%07.0f" % report[:m]}, k=#{"%02.0f" % report[:k]} include?     #{"%10.0f" % (keys.size / report[:includes].real)} ops/s")
end

puts("\nbenchmarking WITH expiration for #{slots.map(&:size).reduce(&:+)} keys with #{ERRORS.map{|e| "#{e * 100}%"}.join(", ")} error rates")

reports = []
Benchmark.bm(53) do |x|
  TEST_M_K.each do |m, k|
    bf = Bloombroom::ContinuousBloomFilter.new(m, k, 0)
    addincludes = x.report("ContinuousBloomFilter m=#{"%07.0f" % m}, k=#{"%02.0f" % k} add+include") do
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
  puts("ContinuousBloomFilter m=#{"%07.0f" % report[:m]}, k=#{"%02.0f" % report[:k]} add+include #{"%10.0f" % (slots.map(&:size).reduce(&:+) * 2 / report[:addincludes].real)} ops/s")
end
