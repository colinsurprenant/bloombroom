/*
 * based on https://github.com/robey/rbfnv with various fixes from forks
 */

#include <stdint.h>
#include "ruby.h"

#define PRIME32 16777619
#define PRIME64 1099511628211ULL

/**
 * FNV fast hashing algorithm in 32 bits.
 * @see http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash
 */
uint32_t fnv1_32(const char *data, uint64_t len) {
  uint32_t rv = 0x811c9dc5U;
  uint64_t i;
  for (i = 0; i < len; i++) {
    rv = (rv * PRIME32) ^ (unsigned char)(data[i]);
  }
  return rv;
}

/**
 * FNV fast hashing algorithm in 32 bits, variant with operations reversed.
 * @see http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash
 */
uint32_t fnv1a_32(const char *data, uint64_t len) {
  uint32_t rv = 0x811c9dc5U;
  uint64_t i;
  for (i = 0; i < len; i++) {
    rv = (rv ^ (unsigned char)data[i]) * PRIME32;
  }
  return rv;
}

/**
 * FNV fast hashing algorithm in 64 bits.
 * @see http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash
 */
uint64_t fnv1_64(const char *data, uint64_t len) {
  uint64_t rv = 0xcbf29ce484222325ULL;
  uint64_t i;
  for (i = 0; i < len; i++) {
    rv = (rv * PRIME64) ^ (unsigned char)data[i];
  }
  return rv;
}

/**
 * FNV fast hashing algorithm in 64 bits, variant with operations reversed.
 * @see http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash
 */
uint64_t fnv1a_64(const char *data, uint64_t len) {
  uint64_t rv = 0xcbf29ce484222325ULL;
  uint64_t i;
  for (i = 0; i < len; i++) {
    rv = (rv ^ (unsigned char)data[i]) * PRIME64;
  }
  return rv;
}

/* ----- ruby bindings ----- */

VALUE rb_fnv1_32(VALUE self, VALUE data) {
  return UINT2NUM(fnv1_32(RSTRING_PTR(data), RSTRING_LEN(data)));
}

VALUE rb_fnv1a_32(VALUE self, VALUE data) {
  return UINT2NUM(fnv1a_32(RSTRING_PTR(data), RSTRING_LEN(data)));
}

VALUE rb_fnv1_64(VALUE self, VALUE data) {
  return ULL2NUM(fnv1_64(RSTRING_PTR(data), RSTRING_LEN(data)));
}

VALUE rb_fnv1a_64(VALUE self, VALUE data) {
  return ULL2NUM(fnv1a_64(RSTRING_PTR(data), RSTRING_LEN(data)));
}

VALUE rb_class;
VALUE rb_module;

void Init_cext_fnv() {
  rb_module = rb_define_module("Bloombroom");
  rb_class = rb_define_class_under(rb_module, "FNVEXT", rb_cObject);
  rb_define_singleton_method(rb_class, "fnv1_32", rb_fnv1_32, 1);
  rb_define_singleton_method(rb_class, "fnv1a_32", rb_fnv1a_32, 1);
  rb_define_singleton_method(rb_class, "fnv1_64", rb_fnv1_64, 1);
  rb_define_singleton_method(rb_class, "fnv1a_64", rb_fnv1a_64, 1);
}