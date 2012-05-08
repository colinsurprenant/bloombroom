require 'ffi'

module Bloombroom
  class FNVFFI
    extend FFI::Library

    ffi_lib File.dirname(__FILE__) + "/" + (FFI::Platform.mac? ? "ffi_fnv.bundle" : FFI.map_library_name("ffi_fnv"))

    attach_function :c_fnv1_32, :fnv1_32, [:string, :uint32], :uint32
    attach_function :c_fnv1a_32, :fnv1a_32, [:string, :uint32], :uint32
    attach_function :c_fnv1_64, :fnv1_64, [:string, :uint32], :uint64
    attach_function :c_fnv1a_64, :fnv1a_64, [:string, :uint32], :uint64

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