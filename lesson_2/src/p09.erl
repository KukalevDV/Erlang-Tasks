-module(p09).
-export([pack/1]).

-include_lib("eunit/include/eunit.hrl").

pack(L) ->
	p05:reverse(pack(L, nil, [], [])).

pack([H|T], H, Spis_level_1, Acc) ->
	pack(T, H, [H|Spis_level_1], Acc);

pack([H|T], nil, _, Acc) ->
	pack(T, H, [H], Acc);

pack([H|T], _, Spis_level_1, Acc) ->
	pack(T, H, [H], [Spis_level_1|Acc]);

pack([], _, Spis_level_1, Acc) ->
	[Spis_level_1|Acc].
	
pack_test() ->
	?assert(p09:pack([a,a,a,a,b,c,c,a,a,d,e,e,e,e]) =:= [[a,a,a,a],[b],[c,c],[a,a],[d],[e,e,e,e]]).
