-module(p08).
-export([compress/1]).

-include_lib("eunit/include/eunit.hrl").

compress(L) ->
	p05:reverse(compress(L, nil, [])).

compress([H|T], H, Acc) ->
	compress(T, H, Acc);

compress([H|T],_,Acc) ->
	compress(T, H, [H|Acc]);

compress([],_,Acc) ->
	Acc.

compress_test() ->
	?assert(p08:compress([a,a,a,a,b,c,c,a,a,d,e,e,e,e]) =:= [a,b,c,a,d,e]).

