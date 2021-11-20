/* helloworld.c */

#include <erl_nif.h>
#include <time.h>
/* function that returns ERL_NIF_TERM, i.e., an Erlang term in C-land */
static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  time_t seconds;
  seconds = time(NULL);
  char output[50];
  sprintf(output, "The epoch is %ld", seconds);
  return enif_make_string(env, output, ERL_NIF_LATIN1);
}

/* declare functions to export (and corresponding arity) */
static ErlNifFunc nif_funcs[] = {
  {"hello", 0, hello}
};

/* actually export the functions previously declared */
ERL_NIF_INIT(helloworld, nif_funcs, NULL, NULL, NULL, NULL);

