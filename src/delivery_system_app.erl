%%%-------------------------------------------------------------------
%% @doc delivery_system public API
%% @end
%%%-------------------------------------------------------------------

-module(delivery_system_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    % TODO: remove | dev only
    %% sync:start(),
    Dispatch = cowboy_router:compile([
        {'_', [{"/", rest_handler, []}]}
    ]),
    {ok, _} = cowboy:start_clear(
        rest_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    delivery_system_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
