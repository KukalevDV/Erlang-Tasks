-module(p12).
-export([decode_modified/1]).

-include_lib("eunit/include/eunit.hrl").

decode_modified(L) ->
	p05:reverse(decode_modified(L, [])).

decode_modified([], Acc) ->
	Acc;

decode_modified([{Kol, Simv}|T], Acc) ->
	decode_modified(T, replec(Kol, Simv, Acc));

decode_modified([Simv|T], Acc) ->
	decode_modified(T, [Simv|Acc]).
	
replec(0,_,Acc) ->
	Acc;

replec(Kol,Simv,Acc) ->
	replec(Kol-1, Simv, [Simv|Acc]).

decode_modified_test() ->
	?assert(p12:decode_modified([{4,a},b,{2,c},{2,a},d,{4,e}]) =:= [a,a,a,a,b,c,c,a,a,d,e,e,e,e]).
