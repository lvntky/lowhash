#ifndef LOWHASH_H_
#define LOWHASH_H_

#include <stdbool.h>
#include <stddef.h>

typedef struct lowhash_node {
  void *key;
  void *value;
  int hash_code;
  struct lowhash_node *next;
} lowhash_node_t;

typedef struct lowhash {
  lowhash_node_t **buckets;
  size_t bucket_size;
  size_t num_buckets;

  void (*clear)(lowhash_t *hash);
  bool (*contains)(lowhash_t *hash, void *key);
  bool (*is_empty)(lowhash_t *hash);
  void *(*get)(lowhash_t *hash, void *key);
  void *(*get_or_default)(lowhash_t *hash, void *key, void *def_val);
  bool (*put)(lowhash_t *hash, void *key, void *value);
  bool (*remove)(lowhash_t *hash, void *key);
  void (*destroy)(lowhash_t *hash);
} lowhash_t;

/**
 * @brief      Public api Functions
 */
lowhash_t *lowhash_create(size_t initial_capacity, hash_func_t hash_func,
                          key_equals_func_t key_equals);
void lowhash_destroy(lowhash_t *hash);

#endif // LOWHASH_H_
