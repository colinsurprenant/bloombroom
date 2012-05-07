$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../'

require 'benchmark/memory'
require 'lib/bloombroom/streaming_bloom_filter'


BLOOMFILTER_SIZE = 10000000

puts("streaming bloomfilter capacity=#{BLOOMFILTER_SIZE}keys, size=#{BLOOMFILTER_SIZE * Bloombroom::StreamingBloomFilter::BITS_PER_BUCKET}bits / #{((BLOOMFILTER_SIZE * Bloombroom::StreamingBloomFilter::BITS_PER_BUCKET) / 8) / 1024}k")

before = Bloombroom::Process.rss
bf = Bloombroom::StreamingBloomFilter.new(BLOOMFILTER_SIZE, 1, 0)
after = Bloombroom::Process.rss

puts("process size before=#{before}k, after=#{after}k")
puts("process size growth=#{(after - before)}k" )