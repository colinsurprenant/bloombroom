require "bundler/setup"
require "benchmark"
require "digest/md5"
require "digest/sha1"
require "bloombroom"

n = 2000000

def warm_and_bench(x, name, &bench)
  bench.call if RUBY_PLATFORM =~ /java/ # warm JVM
  x.report(name, &bench)
end

puts("benchmarking for #{n} iterations")
Benchmark.bm(18) do |x|
  t_md5 =         warm_and_bench(x, "MD5:")               { n.times do ; Digest::MD5.digest('abc123:342453465543223234234'); end }
  t_sha1 =        warm_and_bench(x, "SHA-1:")             { n.times do ; Digest::SHA1.digest('abc123:342453465543223234234'); end }
  t_fnv_a_32 =    warm_and_bench(x, "native FNV A 32:")   { n.times do ; Bloombroom::FNVA.fnv1_32('abc123:342453465543223234234'); end }
  t_fnv_a_64 =    warm_and_bench(x, "native FNV A 64:")   { n.times do ; Bloombroom::FNVA.fnv1_64('abc123:342453465543223234234'); end }
  t_fnv_b_32 =    warm_and_bench(x, "native FNV B 32:")   { n.times do ; Bloombroom::FNVB.fnv1_32('abc123:342453465543223234234'); end }
  t_fnv_b_64 =    warm_and_bench(x, "native FNV B 64:")   { n.times do ; Bloombroom::FNVB.fnv1_64('abc123:342453465543223234234'); end }
  t_fnv_ffi_32 =  warm_and_bench(x, "ffi FNV 32:")        { n.times do ; Bloombroom::FNVFFI.fnv1_32('abc123:342453465543223234234'); end }
  t_fnv_ffi_64 =  warm_and_bench(x, "ffi FNV 64:")        { n.times do ; Bloombroom::FNVFFI.fnv1_64('abc123:342453465543223234234'); end }

  unless RUBY_PLATFORM =~ /java/
    t_fnv_ext_32 =  x.report("c-ext FNV 32:")      { n.times do ; Bloombroom::FNVEXT.fnv1_32('abc123:342453465543223234234'); end }
    t_fnv_ext_64 =  x.report("c-ext FNV 64:")      { n.times do ; Bloombroom::FNVEXT.fnv1_64('abc123:342453465543223234234'); end }
  end

  puts("\n")
  puts("MD5:               #{"%10.0f" % (n / t_md5.real)} ops/s")
  puts("SHA-1:             #{"%10.0f" % (n / t_sha1.real)} ops/s")
  puts("native FNV A 32:   #{"%10.0f" % (n / t_fnv_a_32.real)} ops/s")
  puts("native FNV A 64:   #{"%10.0f" % (n / t_fnv_a_64.real)} ops/s")
  puts("native FNV B 32:   #{"%10.0f" % (n / t_fnv_b_32.real)} ops/s")
  puts("native FNV B 64:   #{"%10.0f" % (n / t_fnv_b_64.real)} ops/s")
  puts("ffi FNV 32:        #{"%10.0f" % (n / t_fnv_ffi_32.real)} ops/s")
  puts("ffi FNV 64:        #{"%10.0f" % (n / t_fnv_ffi_64.real)} ops/s")
  unless RUBY_PLATFORM =~ /java/
    puts("c-ext FNV 32:      #{"%10.0f" % (n / t_fnv_ext_32.real)} ops/s")
    puts("c-ext FNV 64:      #{"%10.0f" % (n / t_fnv_ext_64.real)} ops/s")
  end
end
