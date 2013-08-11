require 'spec_helper'
# require 'bloombroom/filter/counting_bloom_filter'
# require 'bloombroom/filter/bloom_helper'

describe Bloombroom::CountingBloomFilter do

  it "should exist" do
    bf = Bloombroom::CountingBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10, 0.001))
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

  it "should set" do
    bf = Bloombroom::CountingBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10, 0.001))
    bf.set("abc1", 10).should == 10
    bf.set("abc2", 8).should == 8
    bf.set("abc3", 6).should == 6
    bf.set("abc3", 0).should == 0
  end

  it "should add" do
    bf = Bloombroom::CountingBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10, 0.001))
    bf.set("abc1", 2).should == 2
    bf.set("abc2", 4).should == 4

    bf.add("abc1").should == 3
    bf.add("abc1", 3).should == 6

    bf.add("abc2", 5).should == 9
    bf.add("abc2").should == 10

    bf.add("abc3", 3).should == 3
    bf.add("abc3").should == 4
  end

  it "should subtract" do
    bf = Bloombroom::CountingBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10, 0.001))
    bf.set("abc1", 10).should == 10
    bf.set("abc2", 8).should == 8

    bf.subtract("abc1").should == 9
    bf.subtract("abc2", 6).should == 2

    bf.subtract("abc1", 3).should == 6
    bf.subtract("abc2").should == 1
  end

  it "should clear" do
    bf = Bloombroom::CountingBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10, 0.001))
    bf.set("abc1", 10).should == 10
    bf.set("abc2", 8).should == 8

    bf.clear("abc1").should == 0
    bf.clear("abc2").should == 0

    bf.include?("abc1").should be_false
    bf.include?("abc2").should be_false
  end

  it "should find m and k" do
    bf = Bloombroom::CountingBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10000, 0.001))
    bf.m.should == 143776
    bf.k.should == 10
    bf.b.should == 16
    bf.roll_over.should == false
    bf.bits_per_bucket.should == 4
  end

  it "should not roll over" do
    bf = Bloombroom::CountingBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10000, 0.001))
    bf.set("abc1", 8).should == 8
    bf.set("abc2", 4).should == 4

    bf.add("abc1", 9).should == 15
    bf.subtract("abc2", 6).should == 0
  end

  it "should roll over" do
    bf = Bloombroom::CountingBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10000, 0.001), true)
    bf.set("abc1", 8).should == 8
    bf.set("abc2", 4).should == 4

    bf.add("abc1", 21).should == 13
    bf.subtract("abc2", 6).should == 14
  end


end
