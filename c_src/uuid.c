/* uuid.c */

#include <erl_nif.h>
#include <stdint.h>
#include <stdio.h>

#include "uuid4.h"

static uint64_t seed[2];

static uint64_t xorshift128plus(uint64_t *s) {
  /* http://xorshift.di.unimi.it/xorshift128plus.c */
  uint64_t s1 = s[0];
  const uint64_t s0 = s[1];
  s[0] = s0;
  s1 ^= s1 << 23;
  s[1] = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5);
  return s[1] + s0;
}

int uuid4_init(void) {
  int res;
  FILE *fp = fopen("/dev/urandom", "rb");
  if (!fp) {
    return UUID4_EFAILURE;
  }
  res = fread(seed, 1, sizeof(seed), fp);
  fclose(fp);
  if (res != sizeof(seed)) {
    return UUID4_EFAILURE;
  }
  return UUID4_ESUCCESS;
}

void uuid4_generate(char *dst) {
  static const char *template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx";
  static const char *chars = "0123456789abcdef";
  union {
    unsigned char b[16];
    uint64_t word[2];
  } s;
  const char *p;
  int i, n;
  /* get random */
  s.word[0] = xorshift128plus(seed);
  s.word[1] = xorshift128plus(seed);
  /* build string */
  p = template;
  i = 0;
  while (*p) {
    n = s.b[i >> 1];
    n = (i & 1) ? (n >> 4) : (n & 0xf);
    switch (*p) {
      case 'x':
        *dst = chars[n];
        i++;
        break;
      case 'y':
        *dst = chars[(n & 0x3) + 8];
        i++;
        break;
      default:
        *dst = *p;
    }
    dst++, p++;
  }
  *dst = '\0';
}

/* function that returns ERL_NIF_TERM, i.e., an Erlang term in C-land */

static ERL_NIF_TERM uuid4(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  // https://github.com/rxi/uuid4#usage

  char buf[UUID4_LEN];
  uuid4_init();
  uuid4_generate(buf);

  return enif_make_string(env, buf, ERL_NIF_LATIN1);
}

/* declare functions to export (and corresponding arity) */
static ErlNifFunc nif_funcs[] = {{"uuid4", 0, uuid4}};

/* actually export the functions previously declared */
ERL_NIF_INIT(uuid, nif_funcs, NULL, NULL, NULL, NULL);
