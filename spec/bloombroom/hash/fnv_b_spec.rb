require 'spec_helper'
require 'bloombroom/hash/fnv_b'
require 'bloombroom/hash/test_vectors'

describe Bloombroom::FNVB do

  it "should generate fnv1_32" do
    FNV1_32_VECTOR.each do |k, v|
      Bloombroom::FNVB.fnv1_32(k).should == v
    end
  end

  it "should generate fnv1a_32" do
    FNV1A_32_VECTOR.each do |k, v|
      Bloombroom::FNVB.fnv1a_32(k).should == v
    end
  end

  it "should generate fnv1_64" do
    FNV1_64_VECTOR.each do |k, v|
      Bloombroom::FNVB.fnv1_64(k).should == v
    end
  end

  it "should generate fnv1a_64" do
    FNV1A_64_VECTOR.each do |k, v|
      Bloombroom::FNVB.fnv1a_64(k).should == v
    end
  end

end
