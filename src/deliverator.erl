-module(deliverator).

-behaviour(gen_server).

-export([start/0, init/1, handle_cast/2]).
-export([deliver_packages/2]).

% helpers
crash_factor() ->
    S0 = rand:seed_s(exsss),
    {R, _} = rand:uniform_s(S0),
    R.

deliver_packages(Pid, Packages) ->
    gen_server:cast(Pid, {deliver_packages, Packages}).

make_delivery(_Package) ->
    % sleep up to 3 seconds
    timer:sleep(trunc(rand:uniform() * 3000)),
    maybe_crash().

maybe_crash() ->
    R = crash_factor(),
    io:format("Crash factor ~p.~n", [R]),
    case R > 0.6 of
        false ->
            ok;
        true ->
            io:format("Delivery of package failed.~n"),
            error(crash)
    end.

deliver([Package | RemainigPackages]) ->
    io:format("Deliverator ~p delivering ~p.~n", [self(), Package]),
    make_delivery(Package),
    whereis(reciever) ! {package_delivered, Package},
    deliver(RemainigPackages);
deliver([]) ->
    exit(self(), normal).

start() ->
    gen_server:start(?MODULE, [], []).

init(_Args) ->
    {ok, []}.

handle_cast({deliver_packages, Packages}, State) ->
    deliver(Packages),
    {noreply, State}.
