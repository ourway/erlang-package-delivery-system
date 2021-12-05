-module(ranch_tests).

-export([run/0]).

run() ->
    {ok, _} = ranch:start_listener(
        tcp_echo,
        ranch_tcp,
        #{socket_opts => [{port, 5555}, {max_connections, 1000}]},
        echo_protocol,
        []
    ).
