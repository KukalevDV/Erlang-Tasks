-module(p05).
-export([reverse/1]).

-include_lib("eunit/include/eunit.hrl").

reverse(L) ->
	reverse(L, []).

reverse ([], Acc) ->
	Acc;
reverse ([H|T], Acc) ->
	reverse (T, [H|Acc]). 

reverse_test() ->
	?assert(p05:reverse([1,2,3]) =:= [3,2,1]).

