-module(p07).
-export([flatten/1]).

-include_lib("eunit/include/eunit.hrl").

flatten(L) ->
	p05:reverse(flatten(L, [])).

flatten([], Acc) ->
	Acc;

flatten([[]|T], Acc) ->
	flatten(T,Acc);

flatten([[_|_]|_] = [H|T], Acc) ->
	flatten(T,flatten(H,Acc));

flatten([H|T], Acc) ->
	flatten(T,[H|Acc]).
	
flatten_test() ->
	?assert(p07:flatten([a,[],[b,[c,d],e]]) =:= [a,b,c,d,e]).
