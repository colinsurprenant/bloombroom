# inspired by Peter Cooper's http://snippets.dzone.com/posts/show/4234
#
# create a bit field 1000 bits wide
#   bf = BitField.new(1000)
#
#   bf[100] = 1 or bf.set(100)
#   bf[100] => 1 or bg.get(100) => 1
#   bf[100] = 0 or bf.unset(100)
#   bf.zero?(100) => true
#
#   bf.to_s = "10101000101010101"
#   bf.total_set => 10  (example - 10 bits are set to "1")

module Bloombroom
  class BitField
    attr_reader :size
    include Enumerable

    ELEMENT_WIDTH = 32
    ELEMENT_PACK = 'L'

    # @param size [Fixnum] filter size in bits
    # @param bytes [String] the raw contents obtanined using {#to_bytes}
    def self.from_bytes size, bytes
      new size, bytes.unpack("#{ELEMENT_PACK}*")
    end

    def initialize(size, field=nil)
      @size = size
      @field = field || Array.new(((size - 1) / ELEMENT_WIDTH) + 1, 0)
    end

    # set a bit
    # @param position [Fixnum] bit position
    # @param value [Fixnum] bit value 0/1
    def []=(position, value)
      if value == 0
        @field[position / ELEMENT_WIDTH] &= ~(1 << (position % ELEMENT_WIDTH))
      else
        @field[position / ELEMENT_WIDTH] |= 1 << (position % ELEMENT_WIDTH)
      end
    end

    # read a bit
    # @param position [Fixnum] bit position
    # @return [Fixnum] bit value 0/1
    def [](position)
      @field[position / ELEMENT_WIDTH] & 1 << (position % ELEMENT_WIDTH) > 0 ? 1 : 0
    end
    alias_method :get, :[]

    # set a bit to 1
    # @param position [Fixnum] bit position
    def set(position)
      # duplicated code to avoid a method call
      @field[position / ELEMENT_WIDTH] |= 1 << (position % ELEMENT_WIDTH)
    end

    # set a bit to 0
    # @param position [Fixnum] bit position
    def unset(position)
      # duplicated code to avoid a method call
      @field[position / ELEMENT_WIDTH] &= ~(1 << (position % ELEMENT_WIDTH))
    end

    # check if bit is set
    # @param position [Fixnum] bit position
    # @return [Boolean] true if bit is set
    def include?(position)
      @field[position / ELEMENT_WIDTH] & 1 << (position % ELEMENT_WIDTH) > 0
    end

    # check if bit is not set
    # @param position [Fixnum] bit position
    # @return [Boolean] true if bit is not set
    def zero?(position)
      # duplicated code to avoid a method call
      @field[position / ELEMENT_WIDTH] & 1 << (position % ELEMENT_WIDTH) == 0
    end

    # iterate over each bit
    def each(&block)
      @size.times { |position| yield self[position] }
    end

    # returns the field as a string like "0101010100111100," etc.
    def to_s
      inject("") { |a, b| a + b.to_s }
    end

    # return the field as a string containing the raw binary representation of it's content
    def to_bytes
      @field.pack "#{ELEMENT_PACK}*"
    end

    # returns the total number of bits that are set
    # (the technique used here is about 6 times faster than using each or inject direct on the bitfield)
    def total_set
      @field.inject(0) { |a, byte| a += byte & 1 and byte >>= 1 until byte == 0; a }
    end
  end
end
