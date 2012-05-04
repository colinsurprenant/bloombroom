require 'spec_helper'
require 'bloombroom/bloom_helper'

describe Bloombroom::BloomHelper do

  it "should multi_hash" do
    h = Bloombroom::BloomHelper.multi_hash("feedfacedeadbeef", 5)
    h.size.should == 5
    # test vector for fnv1a_64 for "feedfacedeadbeef" -> 0xcac54572bb1a6fc8
    h.should == Array.new(5) {|i| ((0xcac54572bb1a6fc8 & 0xFFFFFFFF00000000) >> 32) + (0xcac54572bb1a6fc8 & 0xFFFFFFFF) * (i + 1)}
  end

  it "should find m and k" do
    Bloombroom::BloomHelper.find_m_k(10000, 0.01).should == [95851, 7]
    Bloombroom::BloomHelper.find_m_k(10000, 0.001).should == [143776, 10]
  end

end
