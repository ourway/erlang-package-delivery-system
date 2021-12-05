-module(echo_protocol).
-behaviour(ranch_protocol).

-export([start_link/4]).
-export([init/4]).

start_link(Ref, Sock, Transport, Opts) ->
    Pid = spawn_link(?MODULE, init, [Ref, Sock, Transport, Opts]),
    {ok, Pid}.

init(Ref, Sock, Transport, _Opts = []) ->
    {ok, Sock} = ranch:handshake(Ref),
    loop(Sock, Transport).

loop(Socket, Transport) ->
    case Transport:recv(Socket, 0, 60000) of
        {ok, Data} when Data =/= <<4>> ->
            Transport:send(Socket, Data),
            loop(Socket, Transport);
        _ ->
            ok = Transport:close(Socket)
    end.
