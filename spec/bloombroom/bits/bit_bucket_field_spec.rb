require 'spec_helper'
# require 'bloombroom/bits/bit_bucket_field'

describe Bloombroom::BitBucketField do

  it "should be all unset at initialization" do
    bf = Bloombroom::BitBucketField.new(8, 100)
    100.times.each do |i|
      bf[i].should == 0
    end
    bf.total_set.should == 0
  end

  it "should set value" do
    bf = Bloombroom::BitBucketField.new(4, 16)

    16.times.each do |i| 
      bf[0] = i
      bf[2] = i
      bf[4] = i
      bf[6] = i
      bf[8] = i
      bf[0].should == i
      bf[1].should == 0
      bf[2].should == i
      bf[3].should == 0
      bf[4].should == i
      bf[5].should == 0
      bf[6].should == i
      bf[7].should == 0
      bf[8].should == i
    end

    16.times.each do |i| 
      bf[0] = 0
      bf[1] = i
      bf[2] = 0
      bf[3] = i
      bf[4] = 0
      bf[5] = i
      bf[6] = 0
      bf[7] = i
      bf[8] = 0
      bf[0].should == 0
      bf[1].should == i
      bf[2].should == 0
      bf[3].should == i
      bf[4].should == 0
      bf[5].should == i
      bf[6].should == 0
      bf[7].should == i
      bf[8].should == 0
    end

    16.times do |value|
      16.times.each do |i|
        bf[i] = value
      end
      16.times.each do |i|
        bf[i].should == value
      end
    end
  end

  it "should randomly set" do
    bf = Bloombroom::BitBucketField.new(4, 1000)
    random_buckets = Array.new(500) {rand(1000)}.uniq
    random_values = Array.new(random_buckets.size) {rand(16)} # values between 0 and 15
    bucket_value = random_buckets.zip(random_values)
    other_buckets = Array.new(1000) {|i| i} - random_buckets

    bucket_value.each{|b, v| bf[b] = v}
    other_buckets.each{|i| bf[i].should == 0}
    bucket_value.each{|b, v| bf[b].should == v}

    other_buckets.each{|i| bf[i] = 0}
    other_buckets.each{|i| bf[i].should == 0}
    bucket_value.each{|b, v| bf[b].should == v}

    random_buckets.each{|i| bf[i] = 0}
    other_buckets.each{|i| bf[i].should == 0}
    random_buckets.each{|i| bf[i].should == 0}
  end

  it "should report size" do
    bf = Bloombroom::BitBucketField.new(4, 56)
    bf.size.should == 56
  end

  it "should report total_set" do
    bf = Bloombroom::BitBucketField.new(16, 100)
    bf[0] = (2 ** 16) - 1
    bf[1] = (2 ** 16) - 1
    bf[2] = (2 ** 16) - 1
    bf[4] = (2 ** 16) - 1
    bf[50] = 1
    bf.total_set.should == 5

    bf = Bloombroom::BitBucketField.new(4, 1000)
    random_buckets = Array.new(500) {rand(1000)}.uniq
    random_values = Array.new(random_buckets.size) {rand(14) + 1} # values between 1 and 15
    bucket_value = random_buckets.zip(random_values)
    other_buckets = Array.new(1000) {|i| i} - random_buckets

    bucket_value.each{|b, v| bf[b] = v}
    bf.total_set.should == random_buckets.size

    other_buckets.each{|i| bf[i] = 0}
    other_buckets.each{|i| bf[i].should == 0}
    bf.total_set.should == bucket_value.size

    random_buckets.each{|i| bf[i] = 0}
    bf.total_set.should == 0
  end

  it "should produce bit string using to_s" do
    bf = Bloombroom::BitBucketField.new(4, 1)
    bf[0] = 1
    bf.to_s.should == "0001"
    bf.to_s(10).should == "1"
    bf[0] = 15
    bf.to_s.should == "1111"
    bf.to_s(10).should == "15"

    bf = Bloombroom::BitBucketField.new(4, 2)
    bf[0] = 3
    bf[1] = 8
    bf.to_s.should == "0011 1000"
    bf.to_s(10).should == "3 8"

    bf = Bloombroom::BitBucketField.new(4, 8)
    bf[0] = 1
    bf[2] = 2
    bf[4] = 3
    bf[6] = 4
    bf.to_s.should == "0001 0000 0010 0000 0011 0000 0100 0000"
    bf.to_s(10).should == "1 0 2 0 3 0 4 0"

    lambda{bf.to_s(16)}.should raise_error
  end

end