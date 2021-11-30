-module(db).

-define(TIMEOUT, 30000).
-export([squery/2, equery/3]).

squery(PoolName, Sql) ->
    poolboy:transaction(
        PoolName,
        fun(Worker) ->
            gen_server:call(Worker, {squery, Sql}, ?TIMEOUT)
        end,
        ?TIMEOUT
    ).

equery(PoolName, Stmt, Params) ->
    poolboy:transaction(
        PoolName,
        fun(Worker) ->
            gen_server:call(Worker, {equery, Stmt, Params}, ?TIMEOUT)
        end,
        ?TIMEOUT
    ).
