#include <lowhash.h>
#include <lowhash_config.h>

/**
 * @brief      Forward declarations of internal functions
 *
 * @details    See struct lowhash_t
 */
static void lowhash_clear_impl(lowhash_t *hash);
static bool lowhash_contains_impl(lowhash_t *hash, void *key);
static bool lowhash_is_empty_impl(lowhash_t *hash);
static void *lowhash_get_impl(lowhash_t *hash, void *key);
static void *lowhash_get_or_default_impl(lowhash_t *hash, void *key,
                                         void *def_val);
static bool lowhash_put_impl(lowhash_t *hash, void *key, void *value);
static bool lowhash_remove_impl(lowhash_t *hash, void *key);
static void lowhash_destroy_impl(lowhash_t *hash);
static bool lowhash_resize(lowhash_t *hash);

// ============================================================================
// IMPLEMENTATION FUNCTIONS
// ============================================================================
static bool lowhash_is_empty_impl(lowhash_t *hash) {
  return !hash || hash->bucket_size = 0;
}

// ============================================================================
// PUBLIC API
// ============================================================================
lowhash_t *lowhash_create(size_t initial_capacity, hash_func_t hash_func,
                          key_equals_func_t key_equals) {
  if (initial_capacity == 0) {
    initial_capacity = LOWHASH_DEFAULT_CAPACITY;
  }

  if (!hash_func || !key_equals) {
    return NULL; // hash and equeals functions required
  }

  lowhash_t *hash = malloc(sizeof(lowhash_t));
  if (!hash) {
    return NULL;
  }

  hash->buckets = calloc(initial_capacity, sizeof(lowhash_node_t *));
  if (!hash->buckets) {
    free(hash);
    return NULL;
  }

  hash->bucket_count = initial_capacity;
  hash->bucket_size = 0;
  hash->hash_func = hash_func;
  hash->key_equals = key_equals;

  // Assign function pointers
  hash->is_empty = lowhash_is_empty_impl;
}
