-module(p01).
-export([last/1]).

-include_lib("eunit/include/eunit.hrl").

last ([H]) ->
	H;
last ([_|T]) ->
	last(T).

last_test() ->
	?assert(p01:last([a,b,c,d,e,f]) =:= f).

