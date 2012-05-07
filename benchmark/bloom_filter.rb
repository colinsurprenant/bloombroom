$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require "benchmark"
require "digest/sha1"
require 'bloombroom/filter/bloom_filter'

keys = 100000.times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}

if !!(defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby')
  puts("warming JVM...")
  bf = Bloombroom::BloomFilter.new(1000000, 7)
  keys.each{|key| bf.add(key)}
end

puts("benchmarking for #{keys.size} keys")

reports = []
Benchmark.bm(40) do |x|
  [{:m => 1000000, :k => 7}, {:m => 1500000, :k => 11}].each do |h|
    bf = Bloombroom::BloomFilter.new(h[:m], h[:k])
    h[:add] = x.report("BloomFilter add m=#{h[:m]}, k=#{h[:k]}") {keys.each{|key| bf.add(key)}}
    h[:include] = x.report("BloomFilter include? m=#{h[:m]}, k=#{h[:k]}") {keys.each{|key| bf.include?(key)}}
    reports << h
  end
end

puts("\n")

reports.each do |report|
  puts("BloomFilter add m=#{report[:m]}, k=#{report[:k]}        #{"%10.0f" % (keys.size / report[:add].real)} ops/sec")
  puts("BloomFilter include? m=#{report[:m]}, k=#{report[:k]}   #{"%10.0f" % (keys.size / report[:include].real)} ops/sec")
end

