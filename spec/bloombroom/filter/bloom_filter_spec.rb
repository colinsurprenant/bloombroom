require 'spec_helper'
# require 'bloombroom'

describe Bloombroom::BloomFilter do

  it "should add" do
    bf = Bloombroom::BloomFilter.new(1000, 5)
    bf.include?("abc1").should be_false
    bf.include?("abc2").should be_false
    bf.include?("abc3").should be_false

    bf.add("abc1")
    bf.include?("abc1").should be_true
    bf.include?("abc2").should be_false
    bf.include?("abc3").should be_false

    bf.add("abc2")
    bf.include?("abc1").should be_true
    bf.include?("abc2").should be_true
    bf.include?("abc3").should be_false

    bf.add("abc3")
    bf.include?("abc1").should be_true
    bf.include?("abc2").should be_true
    bf.include?("abc3").should be_true
  end

  it "should keep track of size" do
    bf = Bloombroom::BloomFilter.new(1000, 5)
    bf.size.should == 0
    bf.add("abc1")
    bf.size.should == 1
    bf.add("abc2")
    bf.size.should == 2
  end

  it "should find m and k" do
    bf = Bloombroom::BloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10000, 0.001))
    bf.m.should == 143776
    bf.k.should == 10
  end

end
