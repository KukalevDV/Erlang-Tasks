-module(p13).
-export([decode/1]).

-include_lib("eunit/include/eunit.hrl").

decode(L) ->
	p05:reverse(decode(L, [])).

decode([], Acc) ->
	Acc;

decode([{Kol, Simv}|T], Acc) ->
	decode(T, replec(Kol, Simv, Acc)).

replec(0,_,Acc) ->
	Acc;

replec(Kol,Simv,Acc) ->
	replec(Kol-1, Simv, [Simv|Acc]).

decode_test() ->
	?assert(p13:decode([{4,a},{1,b},{2,c},{2,a},{1,d},{4,e}]) =:= [a,a,a,a,b,c,c,a,a,d,e,e,e,e]).
