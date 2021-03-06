-module(readers_writers).
-behaviour(gen_server_qcpre).

-include_lib("edbc.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3, cpre/3]).

-export([start/0, request_read/0, finish_read/0, request_write/0, finish_write/0, stop/0]).

-record(state, 
	{
		readers = 0,
		writer = false,
		first_waiting = none,
		prev_state = none
	}).

% These are all wrappers for calls to the server
start() ->
	gen_server_qcpre:start_link({local, ?MODULE}, ?MODULE, [], []).
request_read() -> 
	gen_server_qcpre:call(?MODULE, request_read, infinity).	
finish_read() -> 
	gen_server_qcpre:cast(?MODULE, finish_read).
request_write() ->
	gen_server_qcpre:call(?MODULE, request_write, infinity).	
finish_write() -> 
	gen_server_qcpre:cast(?MODULE, finish_write).
stop() -> 
	gen_server_qcpre:stop(?MODULE).

?INVARIANT(fun invariant/1).

invariant(
	State = 
		#state{
			readers = Readers, 
			writer = Writer
		}
	) -> 
	% io:format("State: ~p\n" ,[State]),
		is_integer(Readers)
	andalso
		Readers >= 0
	andalso 
		is_boolean(Writer)
	andalso
		% Common invariant in readers-writers problem
		((not Writer) orelse Readers == 0)
	.

% This is called when a connection is made to the server
init([]) ->
	{ok, #state{}}.

cpre(request_read, _, State = #state{writer = false, first_waiting = none}) ->
	{
		true, 
		State
	};
cpre(request_read, From, State = #state{writer = false, first_waiting = From}) ->
	{
		true, 
		State
	};
cpre(request_read, From, State = #state{first_waiting = none}) ->
	{
		false,
		State#state{first_waiting = From}
	};
cpre(request_read, From, State) ->
	{
		false,
		State
	};
cpre(request_write, _, State = #state{writer = false, readers = 0, first_waiting = none}) ->
	{
		true, 
		State
	};
cpre(request_write, From, State = #state{writer = false, readers = 0, first_waiting = From}) ->
	{
		true, 
		State
	};
cpre(request_write, From, State = #state{first_waiting = none}) ->
	{
		false,
		State#state{first_waiting = From}
	};
cpre(request_write, From, State) ->
	{
		false,
		State
	};
cpre(_, _, State) ->
	{
		true, 
		State
	}.


% handle_call is invoked in response to gen_server:call
handle_call(request_read, _, State) ->
	{Reply, NState} = 
		{
			pass, 
			State#state{
				readers = State#state.readers + 1,
				first_waiting = none
			}
		},
	{reply, Reply, update_prev_state(State, NState)};
handle_call(request_write, _, State) ->
	{Reply, NState} = 
		{
			pass, 
			State#state{
				writer = true,
				first_waiting = none
			}
		},
	{reply, Reply, update_prev_state(State, NState)};
handle_call(_Message, _From, State) ->
	% io:format("Error: ~p\n", [_Message]),
	{reply, error, State}.


% We get compile warnings from gen_server unless we define these
handle_cast(finish_read, State) ->	
	NState = 
		State#state{
			readers = State#state.readers - 1
		},
	{noreply, update_prev_state(State, NState)};
handle_cast(finish_write, State) ->	
	NState = 
		State#state{
			writer = false
		},
	{noreply, update_prev_state(State, NState)}.

update_prev_state(State, NState) -> 
	NState#state{
		prev_state = State#state{prev_state = none} % To avoid create a useless big structure
	}.

handle_info(_Message, Library) -> 
	{noreply, Library}.
terminate(_Reason, _Library) -> 
	ok.
code_change(_OldVersion, Library, _Extra) -> 
	{ok, Library}.

