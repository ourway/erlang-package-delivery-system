-module(packages).

-export([batch/1]).

-define(OPTIONS,
        ["notebook",
         "mouse",
         "desk",
         "monitor",
         "pencil",
         "bottle",
         "vape",
         "fork",
         "spoon",
         "camera",
         "light",
         "iPad"]).

sanitize(S) ->
    {ok, MP} = re:compile("[/=_+]"),
    re:replace(S, MP, ".", [global, {return, list}]).

select(L) ->
    _ = rand:seed_s(exsss),
    lists:nth(
        rand:uniform(length(L)), L).

rand_id() ->
    binary_to_list(binary:part(
                       base64:encode(
                           crypto:strong_rand_bytes(32)),
                       {0, 10})).

new() ->
    #{"id" => sanitize(rand_id()), "name" => select(?OPTIONS)}.

batch(N) ->
    [new() || _ <- lists:seq(1, N)].
