%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(rest_handler).

-export([init/2]).

init(Req0, State) ->
    Req = cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{key => value}),
        Req0
    ),
    io:format("the state is ~p~n", {Req0}),
    {ok, Req, State}.
