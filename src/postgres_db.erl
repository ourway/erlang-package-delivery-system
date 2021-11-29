-module(postgres_db).
-export([test/0]).

get_connection() ->
    {ok, Connection} = epgsql:connect("localhost", "farsheed", "something", [
        {database, "erl_tests"}
    ]),
    Connection.

test() ->
    Connection = get_connection(),
    {ok, [], []} = epgsql:squery(
        Connection,
        "DROP TABLE IF EXISTS event"
    ),
    {ok, [], []} = epgsql:squery(
        Connection,
        "CREATE TABLE IF NOT EXISTS event"
        "			(_id TEXT PRIMARY KEY, at TIMESTAMP, meta JSONB)"
    ),
    Jdata = jsone:encode(#{learning => <<"Welcome to Erlang and PostgreSQL.">>}),
    {ok, 1} = epgsql:equery(
        Connection,
        "INSERT INTO event (_id, at, meta) "
        "VALUES ('postgres+erlang+rocks', now(), "
        "$1::JSONB)",
        [Jdata]
    ),
    {ok, Cols, Rows} = epgsql:squery(Connection, "SELECT * FROM event"),
    epgsql:close(Connection),
    {ok, Cols, Rows}.
