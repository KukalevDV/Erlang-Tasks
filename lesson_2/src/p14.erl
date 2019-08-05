-module(p14).
-export([duplicate/1]).

-include_lib("eunit/include/eunit.hrl").

duplicate(L) ->
	p05:reverse(duplicate(L, [])).

duplicate([], Acc) ->
	Acc;

duplicate([Simv|T], Acc) ->
	duplicate(T, replec(2, Simv, Acc)).

replec(0,_,Acc) ->
	Acc;

replec(Kol,Simv,Acc) ->
	replec(Kol-1, Simv, [Simv|Acc]).

replec_test() ->
	?assert(p14:duplicate([a,b,c,c,d]) =:= [a,a,b,b,c,c,c,c,d,d]).
