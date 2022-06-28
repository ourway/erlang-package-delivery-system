%%%-------------------------------------------------------------------
%%% @author farsheed
%%% @copyright (C) 2021, farsheed
%%% @doc
%%%
%%% @end
%%% Created : 2021-12-05 18:30:35.030215
%%%-------------------------------------------------------------------
-module(learning_event_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    Str = supervisor:start_link({local, ?SERVER}, ?MODULE, []),
    ok = gen_event:add_handler(learning_event_process, learning_event, []),
    Str.

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @spec init(Args) -> {ok, {SupFlags, [ChildSpec]}} |
%%                     ignore |
%%                     {error, Reason}
%% @end
%%--------------------------------------------------------------------

learning_event_process() ->
    #{
        id => learning_event_process,
        start => {gen_event, start_link, [{local, learning_event_process}]},
        modules => dynamic
    }.

init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    {ok, {SupFlags, [learning_event_process()]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
