-module(tcp_acceptor).

-export([start/0, start/1]).

start() ->
    start(9000).

start(Port) ->
    spawn(fun() -> start_server(Port) end).

start_server(Port) ->
    {ok, Sock} = gen_tcp:listen(Port, [{packet, 0}, {active, false}, {reuseaddr, true}]),
    accept(Sock).

accept(Listen) ->
    case gen_tcp:accept(Listen) of
        {ok, Client} ->
            {ok, _Server} = tcp_relay:start(Client),
            accept(Listen);
        _Error ->
            ok
    end.
