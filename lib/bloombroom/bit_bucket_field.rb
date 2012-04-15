# inspired by Peter Cooper's http://snippets.dzone.com/posts/show/4234
# 
# create a bit bucket field of 100 buckets of 4 bits
#   bf = BitBucketField.new(4, 100)
#
# setting and reading buckets
#   bf[10] = 5 or bf.set(10, 5)
#   bf[10] => 5
#   bf[10] = 0
#
# more
#   bf.to_s = "10101000101010101"  (example)

module Bloombroom
  class BitBucketField
    attr_reader :size
    include Enumerable
    
    ELEMENT_WIDTH = 32
    
    # new BitBucketField
    # @param bits [Fixnum] number of bits per bucket
    # @param size [Fixnum] number of buckets in field
    def initialize(bits, size)
      @size = size
      @bits = bits
      @buckets_per_element = ELEMENT_WIDTH / bits
      @field = Array.new(((size - 1) / @buckets_per_element) + 1, 0)
      @bucket_mask = (2 ** @bits) - 1
    end
    
    # set a bucket
    # @param position [Fixnum] bucket position
    # @param value [Fixnum] bucket value
    def []=(position, value)
      shift_bits = (position % @buckets_per_element) * @bits
      element = position / @buckets_per_element
      if value == 0
        @field[element] &= ~(@bucket_mask << shift_bits)
      else
        @field[element] = (@field[element] & ~(@bucket_mask << shift_bits)) | value << shift_bits
      end
    end
    alias_method :set, :[]=

    # read a bucket
    # @param position [Fixnum] bucket position
    # @return [Fixnum] bucket value
    def [](position)
      shift_bits = (position % @buckets_per_element) * @bits
      (@field[position / @buckets_per_element] & (@bucket_mask << shift_bits)) >> shift_bits
    end
    alias_method :get, :[]
    
    # iterate over each bucket
    def each(&block)
      @size.times { |position| yield self[position] }
    end
    
    # returns the field as a string like "0101010100111100," etc.
    def to_s
      inject("") { |a, b| a + "%0#{@bits}b" % b }
    end    
  end
end