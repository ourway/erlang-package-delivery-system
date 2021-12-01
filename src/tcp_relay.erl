-module(tcp_relay).

-behaviour(gen_server).

-export([start/1]).

%% gen_server callbacks
-export([init/1, handle_cast/2, handle_info/2, terminate/2, code_change/3, handle_call/3]).

-define(SERVER, ?MODULE).
-define(HOST, "127.0.0.1").
-define(PORT, 5001).

-record(state, {client, server}).

% spawn a worker for connection, assign controll to it, then tell the server it can go!

start(Client) ->
    {ok, Pid} = gen_server:start(?MODULE, Client, []),
    gen_tcp:controlling_process(Client, Pid),
    gen_server:cast(Pid, setup_socket),
    {ok, Pid}.

init(Client) ->
    {ok, #state{client = Client}}.

handle_call(_, _From, State) ->
    {reply, ok, State}.
% setup_socket connects to the backend and tells both sockets to be active

handle_cast(setup_socket, #state{client = Client}) ->
    inet:setopts(Client, [{active, once}]),
    case gen_tcp:connect(?HOST, ?PORT, [{active, true}, {packet, 0}]) of
        {ok, Server} ->
            {noreply, #state{client = Client, server = Server}};
        Error ->
            {error, io_lib:format("Relay exception: ~p~n", [Error])}
    end.

% handle connects being closed.... - FIXME - what should happen?

handle_info({tcp_closed, Server}, #state{client = none, server = Server}) ->
    {stop, normal, #state{client = none, server = none}};
handle_info({tcp_closed, Client}, #state{client = Client, server = none}) ->
    {noreply, #state{client = none, server = none}};
handle_info({tcp_closed, Client}, #state{client = Client, server = Server}) ->
    {noreply, #state{client = none, server = Server}};
handle_info({tcp_closed, Server}, #state{client = Client, server = Server}) ->
    {stop, normal, #state{client = Client, server = none}};
% spoon feeding

handle_info({tcp, Client, Data}, #state{client = Client, server = Server} = State) ->
    gen_tcp:send(Server, Data),
    inet:setopts(Client, [{active, once}]),
    {noreply, State};
handle_info({tcp, Server, Data}, #state{client = Client, server = Server} = State) ->
    gen_tcp:send(Client, Data),
    inet:setopts(Server, [{active, once}]),
    {noreply, State}.

terminate(_Reason, #state{client = none, server = none}) ->
    ok;
terminate(_Reason, #state{client = Client, server = none}) ->
    gen_tcp:close(Client),
    ok;
terminate(_Reason, #state{client = none, server = Server}) ->
    gen_tcp:close(Server),
    ok;
terminate(_Reason, #state{client = Client, server = Server}) ->
    gen_tcp:close(Server),
    gen_tcp:close(Client),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
