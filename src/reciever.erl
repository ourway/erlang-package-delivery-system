% Warehouse task reciever

-module(reciever).
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, terminate/2, handle_info/2, handle_cast/2]).
-export([greet/0]).




crash_factor() ->
	S0 = rand:seed_s(exsss),
	{R, _} = rand:uniform_s(S0),
	R.


start_link() ->
	gen_server:start_link({local, reciever}, reciever, [], []).

init(_Args) ->
    process_flag(trap_exit, true),
	{ok, "state1"}.

handle_cast(_Msg, State) ->
	    {noreply, State}.
handle_info({'EXIT', _From, oOps}, State) ->
	io:format("wow~n"),
	{noreply, fine, State}.
handle_call({greet}, _From, State) ->
	R = crash_factor(),
	if 
		R >= 0.6 ->
		   exit(self(), oOps);
	   true ->
			io:format("hello there ~n")
	end,

    {reply, ok, State}.

terminate(_Reason, _State) ->
	logger:error("Something strange happened!"),
    ok.

%% helpers
greet() ->
	gen_server:call(reciever, {greet}).
