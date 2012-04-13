require 'spec_helper'
require 'bloombroom/bloom_filter'

describe Bloombroom::BloomFilter do

  it "should multi_hash" do
    bf = Bloombroom::BloomFilter.new(1000, 5)
    h = bf.multi_hash("feedfacedeadbeef")
    h.size.should == 5
    # test vector for fnv1a_64 for "feedfacedeadbeef" -> 0xcac54572bb1a6fc8
    h.should == Array.new(5) {|i| ((0xcac54572bb1a6fc8 & 0xFFFFFFFF00000000) >> 32) + (0xcac54572bb1a6fc8 & 0xFFFFFFFF) * (i + 1)}
  end

  it "should add" do
    bf = Bloombroom::BloomFilter.new(1000, 5)
    bf.include?("abc1").should be_false
    bf.include?("abc2").should be_false
    bf.include?("abc3").should be_false

    bf.add("abc1")
    bf.include?("abc1").should be_true
    bf.include?("abc2").should be_false
    bf.include?("abc3").should be_false
    bf.bits.total_set.should == 5

    bf.add("abc2")
    bf.include?("abc1").should be_true
    bf.include?("abc2").should be_true
    bf.include?("abc3").should be_false
    bf.bits.total_set.should == 10

    bf.add("abc3")
    bf.include?("abc1").should be_true
    bf.include?("abc2").should be_true
    bf.include?("abc3").should be_true
    bf.bits.total_set.should == 15
  end

end
