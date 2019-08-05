-module(p02).
-export([but_last/1]).

-include_lib("eunit/include/eunit.hrl").

but_last (L = [_,_]) ->
	L;
but_last ([_|T]) ->
	but_last(T).

but_last_test() ->
	?assert(p02:but_last([a,b,c,d,e,f]) =:= [e,f]).
