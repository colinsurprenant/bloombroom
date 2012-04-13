/*
 * taken from https://github.com/robey/rbfnv with 64 bits fixes from forks
 */

#include <stdint.h>

#define PRIME32 16777619
#define PRIME64 1099511628211ULL

/**
 * FNV fast hashing algorithm in 32 bits.
 * @see http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash
 */
uint32_t fnv1_32(const char *data, uint32_t len) {
  uint32_t rv = 0x811c9dc5U;
  uint32_t i;
  for (i = 0; i < len; i++) {
    rv = (rv * PRIME32) ^ (unsigned char)(data[i]);
  }
  return rv;
}

/**
 * FNV fast hashing algorithm in 32 bits, variant with operations reversed.
 * @see http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash
 */
uint32_t fnv1a_32(const char *data, uint32_t len) {
  uint32_t rv = 0x811c9dc5U;
  uint32_t i;
  for (i = 0; i < len; i++) {
    rv = (rv ^ (unsigned char)data[i]) * PRIME32;
  }
  return rv;
}

/**
 * FNV fast hashing algorithm in 64 bits.
 * @see http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash
 */
uint64_t fnv1_64(const char *data, uint32_t len) {
  uint64_t rv = 0xcbf29ce484222325ULL;
  uint32_t i;
  for (i = 0; i < len; i++) {
    rv = (rv * PRIME64) ^ (unsigned char)data[i];
  }
  return rv;
}

/**
 * FNV fast hashing algorithm in 64 bits, variant with operations reversed.
 * @see http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash
 */
uint64_t fnv1a_64(const char *data, uint32_t len) {
  uint64_t rv = 0xcbf29ce484222325ULL;
  uint32_t i;
  for (i = 0; i < len; i++) {
    rv = (rv ^ (unsigned char)data[i]) * PRIME64;
  }
  return rv;
}
