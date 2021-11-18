% Warehouse task reciever

-module(reciever).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_cast/2, handle_info/2, handle_call/3]).
-export([recieve_packages/1]).

-define(MAXC, 128).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

% gen server
init(_Args) ->
    State = #{"assignments" => []},
    {ok, State}.

%handle_info({'EXIT', _From, Reason}, State) ->
%	io:format("Reciever is going down: ~p~n", [Reason]),
%	{noreply, ok, State}.
%

handle_call(_, _From, State) ->
    {reply, ok, State}.

handle_cast({recieve_packages, Packages}, State) ->
    io:format("Recieved ~p packages~n", [length(Packages)]),
    {ok, Deliverator} = deliverator:start(),
    monitor(process, Deliverator),
    NewState = assign_packages(State, Packages, Deliverator),
    deliverator:deliver_packages(Deliverator, Packages),
    {noreply, NewState}.

handle_info({package_delivered, Package}, State) ->
    DeliveredPackages =
        helpers:filter(
            fun(P) -> maps:get("id", P) =:= maps:get("id", Package) end,
            maps:get("assignments", State)
        ),
    NewState =
        maps:update("assignments", maps:get("assignments", State) -- DeliveredPackages, State),
    io:format("Package ~p has been delivered.~n", [Package]),
    {noreply, NewState};
handle_info({'DOWN', _Ref, process, Deliverator, normal}, State) ->
    io:format("Deliverator ~p sucessfully completed.~n", [Deliverator]),
    {noreply, State};
handle_info({'DOWN', _Ref, process, Deliverator, Reason}, State) ->
    io:format("Deliverator ~p crashed because ~p.~n", [Deliverator, Reason]),
    FailedAssignments =
        helpers:filter(
            fun(P) -> maps:get("deliverator", P) =:= Deliverator end,
            maps:get("assignments", State)
        ),
    FailedPackages = helpers:map(fun(A) -> maps:remove("deliverator", A) end, FailedAssignments),
    Assignments = maps:get("assignments", State) -- FailedAssignments,
    NewState = maps:update("assignments", Assignments, State),
    recieve_packages(FailedPackages),
    {noreply, NewState}.

%terminate(_Reason, _State) ->
%	logger:error("Something strange happened!"),
%    ok.

recieve_packages(Packages) ->
    lists:foreach(
        fun(C) -> gen_server:cast(?MODULE, {recieve_packages, C}) end,
        helpers:chunk(Packages, trunc(min(?MAXC, length(Packages) / ?MAXC)))
    ).

assign_packages(State, Packages, Deliverator) ->
    NewAssignments = helpers:map(fun(P) -> maps:put("deliverator", Deliverator, P) end, Packages),
    Assignments = NewAssignments ++ maps:get("assignments", State),
    maps:update("assignments", Assignments, State).
