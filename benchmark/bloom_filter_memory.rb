$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require 'benchmark/memory'
require "bloombroom"

BLOOMFILTER_SIZE = 10000000

puts("bloomfilter capacity=#{BLOOMFILTER_SIZE}keys, size=#{BLOOMFILTER_SIZE}bits / #{(BLOOMFILTER_SIZE / 8) / 1024}k")

before = Bloombroom::Process.rss
bf = Bloombroom::BloomFilter.new(BLOOMFILTER_SIZE, 1)
after = Bloombroom::Process.rss

puts("process size before=#{before}k, after=#{after}k")
puts("process size growth=#{(after - before)}k" )
