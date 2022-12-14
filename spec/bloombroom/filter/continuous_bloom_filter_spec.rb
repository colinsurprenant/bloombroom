require 'spec_helper'
# require 'bloombroom/filter/continuous_bloom_filter'
# require 'bloombroom/filter/bloom_helper'

describe Bloombroom::ContinuousBloomFilter do

  it "should add" do
    bf = Bloombroom::ContinuousBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10, 0.001), 0)
    bf.include?("abc1").should be false
    bf.include?("abc2").should be false
    bf.include?("abc3").should be false

    bf.add("abc1")
    bf.include?("abc1").should be true
    bf.include?("abc2").should be false
    bf.include?("abc3").should be false

    bf.add("abc2")
    bf.include?("abc1").should be true
    bf.include?("abc2").should be true
    bf.include?("abc3").should be false

    bf.add("abc3")
    bf.include?("abc1").should be true
    bf.include?("abc2").should be true
    bf.include?("abc3").should be true
  end

  it "should find m and k" do
    bf = Bloombroom::ContinuousBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(10000, 0.001), 0)
    bf.m.should == 143776
    bf.k.should == 10
  end

  it "should expire" do
    bf = Bloombroom::ContinuousBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(100, 0.001), 0)
    bf.add("abc1")
    bf.include?("abc1").should be true

    bf.inc_time_slot
    bf.add("abc2")
    bf.include?("abc1").should be true
    bf.include?("abc2").should be true

    bf.inc_time_slot
    bf.add("abc3")
    bf.include?("abc1").should be true
    bf.include?("abc2").should be true
    bf.include?("abc3").should be true

    bf.inc_time_slot
    bf.add("abc4")
    bf.include?("abc1").should be false
    bf.include?("abc2").should be true
    bf.include?("abc3").should be true
    bf.include?("abc4").should be true

    bf.inc_time_slot
    bf.include?("abc1").should be false
    bf.include?("abc2").should be false
    bf.include?("abc3").should be true
    bf.include?("abc4").should be true

    bf.inc_time_slot
    bf.include?("abc1").should be false
    bf.include?("abc2").should be false
    bf.include?("abc3").should be false
    bf.include?("abc4").should be true

    bf.inc_time_slot
    bf.include?("abc1").should be false
    bf.include?("abc2").should be false
    bf.include?("abc3").should be false
    bf.include?("abc4").should be false

    bf = Bloombroom::ContinuousBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(100, 0.1), 0)
    keys = []
    1.upto(100) do |i|
      keys << "#{i}test#{i}"
      bf.add(keys.last)
      alive = keys[[keys.size - 3, 0].max, 3]
      expired = keys - alive

      alive.each{|key| bf.include?(key).should be true}
      expired.each{|key| bf.include?(key).should be false}

      bf.inc_time_slot
    end
  end

  it "should compute elapse" do
    bf = Bloombroom::ContinuousBloomFilter.new(*Bloombroom::BloomHelper.find_m_k(100, 0.1), 0)
    bf.send(:elapsed, 1, 1).should == 0
    bf.send(:elapsed, 1, 2).should == 1
    bf.send(:elapsed, 1, 3).should == 2

    bf.send(:elapsed, 2, 14).should == 12
    bf.send(:elapsed, 2, 15).should == 13
    bf.send(:elapsed, 2, 1).should == 14
    bf.send(:elapsed, 3, 1).should == 13
    bf.send(:elapsed, 15, 1).should == 1
    bf.send(:elapsed, 15, 2).should == 2
    bf.send(:elapsed, 15, 14).should == 14
  end


end
