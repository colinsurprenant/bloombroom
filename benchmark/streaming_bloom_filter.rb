$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require "benchmark"
require "digest/sha1"
require 'bloombroom/streaming_bloom_filter'
require 'bloombroom/bloom_helper'

keys = 100000.times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}
slots = 10.times.map{|i| 10000.times.map{|i| Digest::SHA1.hexdigest("#{i}#{rand(1000000)}")}} 

if !!(defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby')
  puts("warming JVM...")
  bf = Bloombroom::SteamingBloomFilter.new(Bloombroom::BloomHelper.find_m_k(150000, 0.001))
  keys.each{|key| bf.add(key)}
end

puts("\nbenchmarking without expiration for #{keys.size} keys")

reports = []
Benchmark.bm(70) do |x|
  [{:m_k => Bloombroom::BloomHelper.find_m_k(150000, 0.1)}, {:m_k => Bloombroom::BloomHelper.find_m_k(150000, 0.01)}, {:m_k => Bloombroom::BloomHelper.find_m_k(150000, 0.001)}].each do |h|
    m_k = h[:m_k] 
    bf = Bloombroom::StreamingBloomFilter.new(*m_k, 0)
    h[:add] = x.report("StreamingBloomFilter add m=#{m_k.first}, k=#{m_k.last}") {keys.each{|key| bf.add(key)}}
    h[:include] = x.report("StreamingBloomFilter include? m=#{m_k.first}, k=#{m_k.last}") {keys.each{|key| bf.include?(key)}}

    h[:addinclude] = x.report("StreamingBloomFilter add/include m=#{m_k.first}, k=#{m_k.last}") do
      slots.each do |slot|
        slot.each{|key| bf.add(key)}
        slot.each{|key| bf.include?(key)}
        bf.inc_time_slot
      end
    end
    reports << h
  end
end

puts("\n")

reports.each do |report|
  puts("StreamingBloomFilter add m=#{report[:m_k].first}, k=#{report[:m_k].last}        #{"%10.0f" % (keys.size / report[:add].real)} ops/sec")
  puts("StreamingBloomFilter include? m=#{report[:m_k].first}, k=#{report[:m_k].last}   #{"%10.0f" % (keys.size / report[:include].real)} ops/sec")
  puts("StreamingBloomFilter add/include m=#{report[:m_k].first}, k=#{report[:m_k].last}        #{"%10.0f" % (keys.size / report[:addinclude].real)} ops/sec")
end


puts("\nbenchmarking with expiration for #{keys.size} keys")

reports = []
Benchmark.bm(70) do |x|
  [{:m_k => Bloombroom::BloomHelper.find_m_k(150000, 0.1)}, {:m_k => Bloombroom::BloomHelper.find_m_k(150000, 0.01)}, {:m_k => Bloombroom::BloomHelper.find_m_k(150000, 0.001)}].each do |h|
    m_k = h[:m_k] 
    bf = Bloombroom::StreamingBloomFilter.new(*m_k, 0)
    h[:addinclude] = x.report("StreamingBloomFilter add/include m=#{m_k.first}, k=#{m_k.last}") do
      slots.each do |slot|
        slot.each{|key| bf.add(key)}
        slot.each{|key| bf.include?(key)}
        bf.inc_time_slot
      end
    end

    reports << h
  end
end

puts("\n")

reports.each do |report|
  puts("StreamingBloomFilter add/include m=#{report[:m_k].first}, k=#{report[:m_k].last}        #{"%10.0f" % (keys.size / report[:addinclude].real)} ops/sec")
end
