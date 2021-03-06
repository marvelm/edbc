# TODO

PRE, POST, ...
==============

- Produce default values instead of an error, i.e. ?PRE(fun.., DefaultValue). An alternative to a different macro is to return {false, {default_value, Value}} in the PRE function.
- Produce a personalized error message for PREs y POSTs, i.e. ?PRE(fun.., ErrorMsg). An alternative to a specific macro is to return {false, Msg}.
- Last two extensions are mutually exclusive. If there is a default value, then there is not sense for an error message, and viceversa. This is automatically done by an specific message error.

- Plantear la posibilidad de que falle más de una PRE o una POST.

- decreases for a recursions a -> b -> a -> b
- One option to do this is by using tracing. Each time a call to the function is detected the check is performed.

- The top of the stack has not postion info. This is unsalvable even by copying attributes from the original form.

- Add a comparsion function to the decrease function so the decision of whether a parameter is decreasing or not is not only done by < or =<.

- Add exception to the contracts


GEN_SERVER_CPRE
===============

- Add to a gen_server_cpre a dictionary as an internal attribute that for each request stores a sorted list of waiting processes. This could ease the starvation checking.
- Add the previous state to the gen_server_cpre, and make the implementation so return an additional element (a flag) in the returned tuples indicaating whether the previous state should be updated. 
- solve starvation problems using invariants 
- Is it needed the old state in the invariant function
- The PRE/POST conditions in the gen_server maybe should make the client fail instead of the server.
- Extend the same approach to other behaviours using state
- It is important to note that the client should perform the call using an infinite timeout. Otherwise, 5000 ms is applied by default and it could result in clients which are already dead when the service is provided.



Other
=====


- It is important that the reported error give an informative information to detect the source of the error. 
- Generate eunit tests from contracts.
- Generate property tests from contracts.
- Invariants when spawning a new process, such as its number of queued messages cannot be greater than 1, etc.
- Introduce locks
- pre in property testing to check that the inputs of a function have always some properties
```
	prop_calls_to_f() ->
	    ?FORALL({A,B}, {integer(),list(integer())},
		    ?PRE_CALLSTO(
		    	fun m:f/3,
		    	[m:g(A,B), m:h(A), m:i(B,A)],
		    	?P(1) > 3 andalso is_integer(?P(1)) andalso ?P(1) + ?P(2) > ?P(3)
		    )
		).
```
- liquid types
- liquid session types
- Add behaviour info as in https://github.com/uwiger/plain_fsm/blob/master/src/plain_fsm.erl 
- Formally propose extension of Erlang 
- use rebar or something to ease compilation and load of the environment


To see
======


- https://www.python.org/dev/peps/pep-0316/
- "Starvation and Critical Race Analyzers for Ada"
- http://www.rise4fun.com/Dafny/
- https://www.youtube.com/watch?v=OcbE6nL1QEk
- https://vimeo.com/148089863
- https://github.com/hyperthunk/annotations
