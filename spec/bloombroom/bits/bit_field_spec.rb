require 'spec_helper'
# require 'bloombroom/bits/bit_field'

describe Bloombroom::BitField do

  it "should be all unset at initialization" do
    bf = Bloombroom::BitField.new(100)
    (0..99).each do |i|
      bf[i].should == 0
      bf.include?(i).should be_false
    end
  end

  it "should set and unset" do
    bf = Bloombroom::BitField.new(1000)
    bf[100].should == 0
    bf.include?(100).should be_false
    bf[101].should == 0
    bf.include?(101).should be_false

    bf[100] = 1
    bf[100].should == 1
    bf.include?(100).should be_true
    bf[100] = 0
    bf[100].should == 0
    bf.include?(100).should be_false

    bf.set(101)
    bf[101].should == 1
    bf.include?(101).should be_true
    bf.unset(101)
    bf[101].should == 0
    bf.include?(101).should be_false
  end

  it "should unset" do
    bf = Bloombroom::BitField.new(100)
    (0..99).each{|i| bf.include?(i).should be_false}
    (0..31).each{|i| bf.unset(i)}
    (0..99).each{|i| bf.include?(i).should be_false}
    
    (0..31).each{|i| bf.set(i)}
    (0..31).each{|i| bf.include?(i).should be_true}
    (32..99).each{|i| bf.include?(i).should be_false}

    unsetbits = [0, 5, 6, 10, 16, 23, 31]
    unsetbits.each{|i| bf.unset(i)}
    ((0..31).map{|i| i} - unsetbits).each{|i| bf.include?(i).should be_true}
    unsetbits.each{|i| bf.include?(i).should be_false}
    (32..99).each{|i| bf.include?(i).should be_false}
  end

  it "should randomly set and unset" do
    bf = Bloombroom::BitField.new(1000)
    random_bits = (0..250).map{|i| rand(1000)}
    other_bits = (0..999).map{|i| i} - random_bits

    random_bits.each{|i| bf.set(i)}
    other_bits.each{|i| bf.include?(i).should be_false}
    random_bits.each{|i| bf.include?(i).should be_true}

    other_bits.each{|i| bf.unset(i)}
    other_bits.each{|i| bf.include?(i).should be_false}
    random_bits.each{|i| bf.include?(i).should be_true}

    random_bits.each{|i| bf.unset(i)}
    other_bits.each{|i| bf.include?(i).should be_false}
    random_bits.each{|i| bf.include?(i).should be_false}
  end

  it "should randomly set and unset and support zero?" do
    bf = Bloombroom::BitField.new(1000)
    random_bits = (0..250).map{|i| rand(1000)}
    other_bits = (0..999).map{|i| i} - random_bits

    random_bits.each{|i| bf.set(i)}
    other_bits.each{|i| bf.zero?(i).should be_true}
    random_bits.each{|i| bf.zero?(i).should be_false}

    other_bits.each{|i| bf.unset(i)}
    other_bits.each{|i| bf.zero?(i).should be_true}
    random_bits.each{|i| bf.zero?(i).should be_false}

    random_bits.each{|i| bf.unset(i)}
    other_bits.each{|i| bf.zero?(i).should be_true}
    random_bits.each{|i| bf.zero?(i).should be_true}
  end

  it "should report size" do
    bf = Bloombroom::BitField.new(456)
    bf.size.should == 456
  end

  it "should produce bit string using to_s" do
    bf = Bloombroom::BitField.new(10)
    bf[1] = 1
    bf[5] = 1
    bf.to_s.should == "0100010000"
  end

  it "should report total_set" do
    bf = Bloombroom::BitField.new(10)
    bf[1] = 1
    bf[5] = 1
    bf.total_set.should == 2
  end

end