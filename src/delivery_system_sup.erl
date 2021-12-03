%%%-------------------------------------------------------------------
%% @doc delivery_system top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(delivery_system_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    %%%%  POSTGRES
    %% {ok, Pools} = application:get_env(delivery_system, pools),
    %% PoolSpecs = lists:map(
    %%     fun({Name, SizeArgs, WorkerArgs}) ->
    %%         PoolArgs =
    %%             [
    %%                 {name, {local, Name}},
    %%                 {worker_module, db_worker}
    %%             ] ++ SizeArgs,
    %%         poolboy:child_spec(Name, PoolArgs, WorkerArgs)
    %%     end,
    %%     Pools
    %% ),
    SupFlags =
        #{
            strategy => one_for_one,
            intensity => 10,
            period => 2
        },
    ChildSpecs =
        [
            #{
                id => reciever_1,
                start => {reciever, start_link, []},
                restart => permanent,
                shutdown => infinity,
                type => worker,
                modules => [reciever]
            },
            #{
                id => deliverator_pool_1,
                start => {deliverator_pool, start_link, []},
                restart => permanent,
                shutdown => infinity,
                type => worker,
                modules => [deliverator_pool2]
            },
            #{
                id => webapp_nodejs,
                start => {webapp_runner, start_link, []},
                restart => permanent,
                shutdown => infinity,
                type => worker,
                modules => [webapp_runner]
            },
            #{
                id => tcp_acceptor,
                start => {tcp_acceptor_server, start_link, []},
                restart => permanent,
                shutdown => infinity,
                type => worker,
                modules => [tcp_acceptor_server]
            }
        ],
    {ok, {
        SupFlags,
        ChildSpecs
        %% ++ PoolSpecs
    }}.

%% internal functions
