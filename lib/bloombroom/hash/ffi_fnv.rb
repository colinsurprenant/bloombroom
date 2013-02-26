require 'ffi'

module Bloombroom
  class FNVFFI
    attach_function :c_fnv1_32, :fnv1_32, [:buffer_in, :uint32], :uint32, :save_errno => false
    attach_function :c_fnv1a_32, :fnv1a_32, [:buffer_in, :uint32], :uint32, :save_errno => false
    attach_function :c_fnv1_64, :fnv1_64, [:buffer_in, :uint32], :uint64, :save_errno => false
    attach_function :c_fnv1a_64, :fnv1a_64, [:buffer_in, :uint32], :uint64, :save_errno => false

    def self.fnv1_32(data)
      c_fnv1_32(data, data.size)
    end

    def self.fnv1_64(data)
      c_fnv1_64(data, data.size)
    end

    def self.fnv1a_32(data)
      c_fnv1a_32(data, data.size)
    end

    def self.fnv1a_64(data)
      c_fnv1a_64(data, data.size)
    end
  end
end