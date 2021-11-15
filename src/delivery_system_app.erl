%%%-------------------------------------------------------------------
%% @doc delivery_system public API
%% @end
%%%-------------------------------------------------------------------

-module(delivery_system_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    delivery_system_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
