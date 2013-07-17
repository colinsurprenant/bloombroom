require 'bundler/setup'
require_relative 'memory'
require "bloombroom"

DEFAULT_M = 10000000
DEFAULT_K = 1
DEFAULT_CAPACITY = 1000000
DEFAULT_ERROR = 0.01

m,k = if ARGV[0] == "auto"
  ARGV.shift
  capacity = (ARGV.shift || DEFAULT_CAPACITY).to_i
  error = (ARGV.shift || DEFAULT_ERROR).to_f
  Bloombroom::BloomHelper.find_m_k(capacity, error)
else
  m = (ARGV.shift || DEFAULT_M).to_i
  k = (ARGV.shift || DEFAULT_K).to_i
  [m ,k]
end

puts("continuous bloomfilter m=#{m}, k=#{k}, size=#{m * Bloombroom::ContinuousBloomFilter::BITS_PER_BUCKET} bits / #{"%.1f" %  (((m * Bloombroom::ContinuousBloomFilter::BITS_PER_BUCKET) / 8) / 1024.0)}k")

before = Bloombroom::Process.rss
bf = Bloombroom::ContinuousBloomFilter.new(m, k, 0)
after = Bloombroom::Process.rss

puts("process size before=#{before}k, after=#{after}k")
puts("process size growth=#{(after - before)}k" )
