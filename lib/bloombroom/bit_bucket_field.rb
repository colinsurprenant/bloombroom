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
      element, offset = position.divmod(@buckets_per_element)
      shift_bits = offset * @bits
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
      element, offset = position.divmod(@buckets_per_element)
      shift_bits = (position % @buckets_per_element) * @bits
      (@field[element] & (@bucket_mask << shift_bits)) >> shift_bits
    end
    alias_method :get, :[]

    def zero?(position)
      element, offset = position.divmod(@buckets_per_element)
      shift_bits = (position % @buckets_per_element) * @bits
      (@field[element] & (@bucket_mask << shift_bits)) == 0
    end

    def inc(position)
    end

    def dec(position)
    end
    
    # iterate over each bucket
    def each(&block)
      @size.times { |position| yield self[position] }
    end
    
    # returns the field as a string like "0101010100111100," etc.
    def to_s(base = 1)
      case base 
      when 1
        inject("") { |a, b| a + "%0#{@bits}b" % b }
      when 10
        self.inject("") { |a, b| a + "%1d " % b }.strip
      else
        raise(ArgumentError, "unsupported base")
      end
    end

    # returns the total number of non zero buckets
    def total_set
      self.inject(0) { |a, bucket| a += bucket.zero? ? 0 : 1; a }
    end

  end
end