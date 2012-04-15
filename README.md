# Bloombroom v0.0.1

Bloombroom - collection of bloomfilters, hashing, bitfields with various native/ext/ffi implementations for speed/compatibility.

This is a work-in-progress. Code is stable but not yet gemified/packaged. This is currently a nice codebase for anyone requiring a BloomFilter,
a (native, C-EXT, FFI) fast FNV hash or a bit field implementation. 
## Installation

Everything has been tested in both Ruby 1.9.2 and JRuby 1.6.7.

``` sh
$ bundle install
$ rake make
```

If switching to/from Ruby/JRuby do not forget to 

``` sh
$ rake clean
$ rake make
```

### Benchmarks

The FNV benchmark is quite interesting as it compares the performance of SHA1, MD5, two native Ruby FNV (A & B) implementations, a C implementation as both a Ruby C extension and as a FFI extension. 

``` sh
$ ruby benchmark/fnv.rb
$ ruby benchmark/bloom_filter.rb
```

## Author
Colin Surprenant, [@colinsurprenant][twitter], [http://github.com/colinsurprenant][github], colin.surprenant@needium.com, colin.surprenant@gmail.com

## License
Bloombroom is distributed under the Apache License, Version 2.0. 

[twitter]: http://twitter.com/colinsurprenant
[github]: http://github.com/colinsurprenant
