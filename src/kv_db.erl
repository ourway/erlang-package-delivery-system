-module(kv_db).

-export([init/0, insert/2, read/1]).

-record(cache, {key, value}).

init() ->
    %% application:set_env(mnesia, dir, Dir),
    Nodes = mnesia:system_info(db_nodes),
    case mnesia:create_schema(Nodes) of
        ok ->
            io:format("Mnesia schemas created~n");
        {error, {_, {already_exists, _}}} ->
            pass;
        {error, {_, {Reason, _}}} ->
            io:format("Mnesia schema creation failed: ~p~n", [Reason])
    end,
    ok = mnesia:start(),

    mnesia:create_table(
        cache,
        [
            {attributes, record_info(fields, cache)},
            {type, set},
            {disc_copies, Nodes},
            {majority, true}
        ]
    ).
insert(Key, Value) ->
    T = fun() ->
        X = #cache{key = Key, value = Value},
        mnesia:write(X)
    end,
    mnesia:transaction(T).

read(Key) ->
    R = fun() ->
        mnesia:read(cache, Key, write)
    end,
    case mnesia:transaction(R) of
        {atomic, [{cache, Key, Value}]} ->
            Value;
        {atomic, []} ->
            err_not_found;
        Error ->
            Error
    end.
