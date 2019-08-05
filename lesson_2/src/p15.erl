-module(p15).
-export([replicate/2]).

-include_lib("eunit/include/eunit.hrl").

replicate(L, Kol) ->
	p05:reverse(replicate(L, Kol, [])).

replicate([], _ , Acc) ->
	Acc;

replicate([Simv|T], Kol, Acc) ->
	replicate(T, Kol, replec(Kol, Simv, Acc)).

replec(0,_,Acc) ->
	Acc;

replec(Kol,Simv,Acc) ->
	replec(Kol-1, Simv, [Simv|Acc]).

replicate_test() ->
	?assert(p15:replicate([a,b,c], 3) =:= [a,a,a,b,b,b,c,c,c]).
