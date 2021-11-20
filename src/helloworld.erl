-module(helloworld).

-export([init/0, hello/0]).

-on_load(init/0).

init() ->
      erlang:load_nif("c_src/helloworld", 0).

hello() ->
	      erlang:nif_error("NIF library not loaded").
