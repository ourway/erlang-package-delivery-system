%%%-------------------------------------------------------------------
%%% @author farsheed
%%% @copyright (C) 2021, farsheed
%%% @doc
%%%
%%% @end
%%% Created : 2021-12-05 04:37:29.718407
%%%-------------------------------------------------------------------
-module(cat_fsm).

-behaviour(gen_statem).

%% API
-export([start_link/0]).

%% gen_statem callbacks
-export([
    callback_mode/0,
    init/1,
    format_status/2,
    state_name/3,
    handle_event/4,
    terminate/3,
    code_change/4
]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Creates a gen_statem process which calls Module:init/1 to
%% initialize. To ensure a synchronized start-up procedure, this
%% function does not return until Module:init/1 has returned.
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_statem callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Define the callback_mode() for this callback module.
%%
%% @spec callback_mode() -> state_functions |
%%                          handle_event_function |
%%                          [state_functions, state_enter] |
%%                          [handle_event_function, state_enter]
%% @end
%%--------------------------------------------------------------------
callback_mode() ->
    state_functions.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_statem is started using gen_statem:start/[3,4] or
%% gen_statem:start_link/[3,4], this function is called by the new
%% process to initialize.
%%
%% @spec init(Args) -> {ok, State, Data} |
%%                     {ok, State, Data, Actions} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    process_flag(trap_exit, true),
    {ok, state_name, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Called (1) whenever sys:get_status/1,2 is called by gen_statem or
%% (2) when gen_statem terminates abnormally.
%% This callback is optional.
%%
%% @spec format_status(Opt, [PDict, State, Data]) -> Status
%% @end
%%--------------------------------------------------------------------
format_status(_Opt, [_PDict, State, Data]) ->
    [{data, [{"State", {State, Data}}]}].

%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name.  If callback_mode is statefunctions, one of these
%% functions is called when gen_statem receives and event from
%% call/2, cast/2, or as a normal process message.
%%
%% @spec state_name(Event, OldState, Data) ->
%%                   {next_state, NextState, NewData} |
%%                   {next_state, NextState, NewData, Actions} |
%%                   {keep_state, NewData} |
%%                   {keep_state, NewData, Actions} |
%%                   keep_state_and_data |
%%                   {keep_state_and_data, Actions} |
%%                   {repeat_state, NewData} |
%%                   {repeat_state, NewData, Actions} |
%%                   repeat_state_and_data |
%%                   {repeat_state_and_data, Actions} |
%%                   stop |
%%                   {stop, Reason} |
%%                   {stop, Reason, NewData} |
%%                   {stop_and_reply, Reason, Replies} |
%%                   {stop_and_reply, Reason, Replies, NewData}
%% @end
%%--------------------------------------------------------------------
state_name({call, Caller}, _Msg, Data) ->
    {next_state, state_name, Data, [{reply, Caller, ok}]}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%%
%% If callback_mode is handle_event_function, then whenever a
%% gen_statem receives an event from call/2, cast/2, or as a normal
%% process message, this function is called.
%%
%% @spec handle_event(Event, StateName, State) ->
%%                   {next_state, NextState, NewData} |
%%                   {next_state, NextState, NewData, Actions} |
%%                   {keep_state, NewData} |
%%                   {keep_state, NewData, Actions} |
%%                   keep_state_and_data |
%%                   {keep_state_and_data, Actions} |
%%                   {repeat_state, NewData} |
%%                   {repeat_state, NewData, Actions} |
%%                   repeat_state_and_data |
%%                   {repeat_state_and_data, Actions} |
%%                   stop |
%%                   {stop, Reason} |
%%                   {stop, Reason, NewData} |
%%                   {stop_and_reply, Reason, Replies} |
%%                   {stop_and_reply, Reason, Replies, NewData}
%% @end
%%--------------------------------------------------------------------
handle_event({call, From}, _Msg, State, Data) ->
    {next_state, State, Data, [{reply, From, ok}]}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_statem when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_statem terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State, Data) -> Ignored
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State, _Data) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, OldState, OldData, Extra) ->
%%                   {ok, NewState, NewData} |
%%                   Reason
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
