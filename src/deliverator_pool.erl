%%%-------------------------------------------------------------------
%%% @author farshid.ashouri
%%% @copyright (C) 2021, farshid.ashouri
%%% @doc
%%%
%%% @end
%%% Created : 2021-11-19 01:37:01.567395
%%%-------------------------------------------------------------------
-module(deliverator_pool).
-behaviour(gen_server).
%% API
-export([
    available_deliverator/0,
    flag_deliverator_busy/1,
    flag_deliverator_idle/1,
    remove_deliverator/1
]).

%% gen_server callbacks
-export([
    start_link/0,
    handle_call/3,
    handle_cast/2,
    init/1
]).

% experimental exports - remvove later
-export([findFirstIdle/1]).

-define(MAX, 20).

findFirstIdle([]) ->
    nil;
findFirstIdle([Item | ListTail]) ->
    case (maps:get("flag", Item) =:= idle) of
        true -> Item;
        false -> findFirstIdle(ListTail)
    end.

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
    io:format("hello from pool~n"),
    State = #{"deliverators" => [], "max" => ?MAX},
    {ok, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_call({fetch_available_deliverator}, _From, State) ->
    Deliverators = maps:get("deliverators", State),
    case (findFirstIdle(Deliverators)) of
        nil ->
            % either maxed out or every pool is busy
            case (length(Deliverators) > ?MAX) of
                true ->
                    {error, "deliverator pool maxed out!", State};
                false ->
                    % we can start a new deliverator
                    {ok, Deliverator} = deliverator:start(),
                    NewDeliverators = [
                        #{"pid" => Deliverator, "flag" => idle} | Deliverators
                    ],
                    NewState = State#{"deliverators" => NewDeliverators},
                    {reply, Deliverator, NewState}
            end;
        #{"pid" := Deliverator} ->
            io:format("found idle deliverator with pid: ~p~n.", [Deliverator]),
            {reply, Deliverator, State}
    end;
handle_call({flag_deliverator, Flag, Deliverator}, _From, State) ->
    {reply, ok, State};
handle_call({remove_deliverator, Deliverator}, _From, State) ->
    {reply, ok, State}.

available_deliverator() ->
    gen_server:call(?MODULE, {fetch_available_deliverator}).

flag_deliverator_busy(Deliverator) ->
    gen_server:call(?MODULE, {flag_deliverator, busy, Deliverator}).

flag_deliverator_idle(Deliverator) ->
    gen_server:call(?MODULE, {flag_deliverator, idle, Deliverator}).

remove_deliverator(Deliverator) ->
    gen_server:call(?MODULE, {remove_deliverator, Deliverator}).
