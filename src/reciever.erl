%%%-------------------------------------------------------------------
%%% @author farshid.ashouri
%%% @copyright (C) 2021, farshid.ashouri
%%% @doc
%%%
%%% @end
%%% Created : 2021-11-19 01:37:01.567395
%%%-------------------------------------------------------------------
-module(reciever).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_cast/2, handle_info/2, handle_call/3]).
-export([recieve_packages/1]).

-define(BATCH_SIZE, 128).

%%
%% Public API
%%
recieve_packages(Packages) ->
    gen_server:cast(?MODULE, {recieve_packages, Packages}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

% gen server
init(_Args) ->
    State = #{
        "assignments" => [],
        "delivered_packages" => [],
        "remaining_packages" => [],
        "buffered_packages" => []
    },
    {ok, State}.

%handle_info({'EXIT', _From, Reason}, State) ->
%	io:format("Reciever is going down: ~p~n", [Reason]),
%	{noreply, ok, State}.
%

handle_call(_, _From, State) ->
    {reply, ok, State}.

handle_cast({recieve_packages, Packages}, State) ->
    io:format("Recieved ~p packages~n", [length(Packages)]),

    case (deliverator_pool:available_deliverator()) of
        {ok, Deliverator} ->
            io:format("Deliverator ~p acquired, assigning new batch.~n", [Deliverator]),
            [PackageBatch | RemainingPackages] = helpers:chunk(Packages, ?BATCH_SIZE),
            monitor(process, Deliverator),
            NewState = assign_packages(State, PackageBatch, Deliverator),
            deliverator_pool:flag_deliverator_busy(Deliverator),
            deliverator:deliver_packages(Deliverator, PackageBatch),
            case (length(RemainingPackages) > 0) of
                true ->
                    recieve_packages(RemainingPackages);
                false ->
                    ok
            end,
            {noreply, NewState};
        {error, Reason} ->
            io:format("can't find any deliverator:~p~n.", [Reason]),
            {noreply, State}
    end.

handle_info({package_delivered, Package}, State) ->
    DeliveredPackages =
        helpers:filter(
            fun(P) -> maps:get("id", P) =:= maps:get("id", Package) end,
            maps:get("assignments", State)
        ),
    NewState =
        maps:update("assignments", maps:get("assignments", State) -- DeliveredPackages, State),
    io:format("Package ~p has been delivered.~n", [Package]),
    {noreply, NewState#{
        "delivered_packages" => (maps:get("delivered_packages", State) ++ DeliveredPackages)
    }};
handle_info({deliverator_idle, Deliverator}, State) ->
    io:format("Deliverator ~p sucessfully completed.~n", [Deliverator]),
    deliverator_pool:flag_deliverator_idle(Deliverator),
    {noreply, State};
handle_info({'DOWN', _Ref, process, Deliverator, Reason}, State) ->
    io:format("Deliverator ~p crashed because ~p.~n", [Deliverator, Reason]),
    FailedAssignments =
        helpers:filter(
            fun(P) -> maps:get("deliverator", P) =:= Deliverator end,
            maps:get("assignments", State)
        ),
    FailedPackages =
        helpers:map(fun(A) -> maps:remove("deliverator", A) end, FailedAssignments),
    Assignments = maps:get("assignments", State) -- FailedAssignments,
    deliverator_pool:remove_deliverator(Deliverator),
    NewState = maps:update("assignments", Assignments, State),
    recieve_packages(FailedPackages),
    {noreply, NewState}.

assign_packages(State, Packages, Deliverator) ->
    NewAssignments =
        helpers:map(fun(P) -> maps:put("deliverator", Deliverator, P) end, Packages),
    Assignments = NewAssignments ++ maps:get("assignments", State),
    maps:update("assignments", Assignments, State).
