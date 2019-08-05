-module(p03).
-export([element_at/2]).

-include_lib("eunit/include/eunit.hrl").


element_at([H|_], 1) ->
	H;
element_at([_|T] ,N) ->
	element_at(T, N-1);
element_at([],_) ->
	undefined.

element_at_test() ->
	?assert(p03:element_at([a,b,c,d,e,f], 4) =:= d),
	?assert(p03:element_at([a,b,c,d,e,f], 10) =:= undefined).
