-module(cmd).

-export([exec/2, run/2]).

run(Command, Dir) ->
    open_port(
        {spawn, Command},
        [use_stdio, stderr_to_stdout, exit_status, {cd, Dir}, {packet, 4}]
    ).

exec(Command, Dir) ->
    Port = open_port(
        {spawn, Command},
        [stream, in, eof, hide, exit_status, {cd, Dir}]
    ),
    get_data(Port, []).

get_data(Port, Sofar) ->
    receive
        {Port, {data, Bytes}} ->
            get_data(Port, [Sofar | Bytes]);
        {Port, eof} ->
            Port ! {self(), close},
            receive
                {Port, closed} ->
                    true
            end,
            receive
                {'EXIT', Port, _} ->
                    ok
                % force context switch
            after 1 ->
                ok
            end,
            ExitCode =
                receive
                    {Port, {exit_status, Code}} ->
                        Code
                end,
            {ExitCode, lists:flatten(Sofar)}
    end.
