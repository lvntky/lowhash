#ifndef LOWHASH_H_
#define LOWHASH_H_

#include <stdbool.h>

typedef struct lh_item {
  void *key;
  void *value;
} lh_item_t;

typedef struct lowhash {
  lh_item_t *hash;
} lowhash_t;

/**
 * @brief      beggining of the public api
 */
void clear(lowhash_t *hash);
bool contains(lowhash_t *hash, void *value);
bool is_empty(lowhash_t *hash);
void *get(void *key);
void *get_or_default(void *key, void *def_val);
void put(lowhash_t *hash, void *key, void *value);

#endif // LOWHASH_H_
