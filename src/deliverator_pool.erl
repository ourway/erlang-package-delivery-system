-module(deliverator_pool).
-behaviour(gen_server).
-export([
    start_link/0,
    handle_call/3,
    handle_cast/2,
    init/1
]).
% public funcitons
-export([
    available_deliverator/0,
    flag_deliverator_busy/1,
    flag_deliverator_idle/1,
    remove_deliverator/1
]).

% experimental exports - remvove later

-define(MAX, 20).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
    io:format("hello from pool~n"),
    State = #{"deliverators" => [], "max" => ?MAX},
    {ok, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_call({fetch_available_deliverator}, _From, State) ->
    {reply, ok, State};
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
