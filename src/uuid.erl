-module(uuid).

-export([init/0, uuid4/0]).

-on_load(init/0).

init() ->
      erlang:load_nif("c_src/uuid", 0).

uuid4() ->
	      erlang:nif_error("NIF library not loaded").
