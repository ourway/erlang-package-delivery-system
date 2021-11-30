%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(rest_handler).

-export([init/2]).

init(Req0, State) ->
    Req = cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"Hello Erlang!">>,
        Req0
    ),
    {ok, Req, State}.
