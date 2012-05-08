require "bundler/setup"
require "benchmark"
require "digest/md5"
require "digest/sha1"
require "bloombroom"

n = 1000000
puts("benchmarking for #{n} iterations")
Benchmark.bm(18) do |x|
  t_md5 =         x.report("MD5:")               { n.times do ; Digest::MD5.digest('abc123:342453465543223234234'); end }
  t_sha1 =        x.report("SHA-1:")             { n.times do ; Digest::SHA1.digest('abc123:342453465543223234234'); end }
  t_fnv_a_32 =    x.report("native FNV A 32:")   { n.times do ; Bloombroom::FNVA.fnv1_32('abc123:342453465543223234234'); end }
  t_fnv_a_64 =    x.report("native FNV A 64:")   { n.times do ; Bloombroom::FNVA.fnv1_64('abc123:342453465543223234234'); end }
  t_fnv_b_32 =    x.report("native FNV B 32:")   { n.times do ; Bloombroom::FNVB.fnv1_32('abc123:342453465543223234234'); end }
  t_fnv_b_64 =    x.report("native FNV B 64:")   { n.times do ; Bloombroom::FNVB.fnv1_64('abc123:342453465543223234234'); end }
  t_fnv_ffi_32 =  x.report("ffi FNV 32:")        { n.times do ; Bloombroom::FNVFFI.fnv1_32('abc123:342453465543223234234'); end }
  t_fnv_ffi_64 =  x.report("ffi FNV 64:")        { n.times do ; Bloombroom::FNVFFI.fnv1_64('abc123:342453465543223234234'); end }
  t_fnv_dffi_32 = x.report("direct ffi FNV 32:") { n.times do ; Bloombroom::FNVFFI.c_fnv1_32('abc123:342453465543223234234', 'abc123:342453465543223234234'.size); end }
  t_fnv_dffi_64 = x.report("direct ffi FNV 64:") { n.times do ; Bloombroom::FNVFFI.c_fnv1_64('abc123:342453465543223234234', 'abc123:342453465543223234234'.size); end }
  t_fnv_ext_32 =  x.report("ext FNV 32:")        { n.times do ; Bloombroom::FNVEXT.fnv1_32('abc123:342453465543223234234'); end }
  t_fnv_ext_64 =  x.report("ext FNV 64:")        { n.times do ; Bloombroom::FNVEXT.fnv1_64('abc123:342453465543223234234'); end }

  puts("\n")
  puts("MD5:               #{"%10.0f" % (n / t_md5.real)} ops/s")
  puts("SHA-1:             #{"%10.0f" % (n / t_sha1.real)} ops/s")
  puts("native FNV A 32:   #{"%10.0f" % (n / t_fnv_a_32.real)} ops/s")
  puts("native FNV A 64:   #{"%10.0f" % (n / t_fnv_a_64.real)} ops/s")
  puts("native FNV B 32:   #{"%10.0f" % (n / t_fnv_b_32.real)} ops/s")
  puts("native FNV B 64:   #{"%10.0f" % (n / t_fnv_b_64.real)} ops/s")
  puts("ffi FNV 32:        #{"%10.0f" % (n / t_fnv_ffi_32.real)} ops/s")
  puts("ffi FNV 64:        #{"%10.0f" % (n / t_fnv_ffi_64.real)} ops/s")
  puts("direct ffi FNV 32: #{"%10.0f" % (n / t_fnv_dffi_32.real)} ops/s")
  puts("direct ffi FNV 64: #{"%10.0f" % (n / t_fnv_dffi_64.real)} ops/s")
  puts("ext FNV 32:        #{"%10.0f" % (n / t_fnv_ext_32.real)} ops/s")
  puts("ext FNV 64:        #{"%10.0f" % (n / t_fnv_ext_64.real)} ops/s")
end
