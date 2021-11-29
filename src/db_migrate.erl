-module(db_migrate).

-define(POOL, pool1).
-export([up/0, init/0, hash/1]).

init() ->
    MigrationTableQeury =
        "		DROP TABLE IF EXISTS _migration_info;\n"
        "		CREATE TABLE IF NOT EXISTS _migration_info (\n"
        "			id SERIAL PRIMARY KEY,\n"
        "			file TEXT NOT NULL,\n"
        "			hash TEXT NOT NULL,\n"
        "			path ltree NOT NULL\n"
        "		);\n"
        "		CREATE INDEX IF NOT EXISTS path_gist_idx ON _migration_info USING GIST (path);\n"
        "	",
    db:squery(?POOL, MigrationTableQeury).

hash(String) ->
    {ok, Pat} = re:compile("[/=+\/]"),
    re:replace(
        base64:encode_to_string(crypto:hash(sha256, String)),
        Pat,
        "i",
        [global, {return, list}]
    ).

up() ->
    init(),
    PrivDir = code:priv_dir(delivery_system),
    SqlDir = filename:join(PrivDir, "sql"),
    SqlFiles = lists:sort(
        filelib:wildcard(filename:join(SqlDir, "*.sql"))
    ),
    db:squery(?POOL, "Begin;"),
    lists:map(
        fun(F) ->
            %% migration process
            {ok, S} = file:read_file(F),
            db:squery(?POOL, S)
        end,
        SqlFiles
    ),
    db:squery(?POOL, "commit;").
