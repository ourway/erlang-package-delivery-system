%%%-------------------------------------------------------------------
%% @doc mydns public API
%% @end
%%%-------------------------------------------------------------------

-module(mydns_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    mydns_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
