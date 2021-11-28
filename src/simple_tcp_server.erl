-module(simple_tcp_server).

%% define tcp options
%% usage:
%% >>> simple_tcp_server:start(100, 10000).

-define(TCP_OPTIONS, [list, {packet, 0}, {active, false}, {reuseaddr, true}]).

-export([start/2, server/1]).
start(Num, LPort) ->
    case gen_tcp:listen(LPort, ?TCP_OPTIONS) of
        {ok, ListenSock} ->
            start_servers(Num, ListenSock),
            {ok, Port} = inet:port(ListenSock),
            Port;
        {error, Reason} ->
            {error, Reason}
    end.

start_servers(0, _) ->
    ok;
start_servers(Num, LS) ->
    spawn(?MODULE, server, [LS]),
    start_servers(Num - 1, LS).

server(LS) ->
    case gen_tcp:accept(LS) of
        {ok, S} ->
            loop(S),
            server(LS);
        Other ->
            io:format("accept returned ~w - goodbye!~n", [Other]),
            ok
    end.

loop(S) ->
    inet:setopts(S, [{active, once}]),
    receive
        {tcp, S, Data} ->
            gen_tcp:send(S, Data),
            loop(S);
        {tcp_closed, S} ->
            io:format("Socket ~w closed [~w]~n", [S, self()]),
            ok
    end.
