$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require "benchmark"
require "digest/sha1"
require "bloombroom"

KEYS_COUNT = 150000
ERRORS = [0.01, 0.001, 0.0001]
TEST_M_K = ERRORS.map{|error| Bloombroom::BloomHelper.find_m_k(KEYS_COUNT, error)}

keys = KEYS_COUNT.times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}

if !!(defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby')
  puts("warming JVM...")
  bf = Bloombroom::BloomFilter.new(KEYS_COUNT, 7)
  keys.each{|key| bf.add(key)}
end

puts("benchmarking for #{keys.size} keys with #{ERRORS.map{|e| "#{e * 100}%"}.join(", ")} error rates")

reports = []
Benchmark.bm(40) do |x|
  TEST_M_K.each do |m, k|
    bf = Bloombroom::BloomFilter.new(m, k)
    adds = x.report("BloomFilter m=#{"%07.0f" % m}, k=#{"%02.0f" % k} add") {keys.each{|key| bf.add(key)}}
    includes = x.report("BloomFilter m=#{"%07.0f" % m}, k=#{"%02.0f" % k} include?") {keys.each{|key| bf.include?(key)}}
    reports << {:m => m, :k => k, :adds => adds, :includes => includes}
  end
end

puts("\n")

reports.each do |report|
  puts("BloomFilter m=#{"%07.0f" % report[:m]}, k=#{"%02.0f" % report[:k]} add        #{"%10.0f" % (keys.size / report[:adds].real)} ops/s")
  puts("BloomFilter m=#{"%07.0f" % report[:m]}, k=#{"%02.0f" % report[:k]} include?   #{"%10.0f" % (keys.size / report[:includes].real)} ops/s")
end
