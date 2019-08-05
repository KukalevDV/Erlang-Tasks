-module(p10).
-export([encode/1]).

-include_lib("eunit/include/eunit.hrl").

encode(L) ->
	p05:reverse(encode(L, nil, 0, [])).

encode([H|T], H, Kol_Povtor, Acc) ->
	encode(T, H, Kol_Povtor + 1, Acc);

encode([H|T], nil, _, Acc) ->
	encode(T, H, 1, Acc);

encode([H|T], Pred_elem, Kol_Povtor, Acc) ->
	encode(T, H, 1,  [{Kol_Povtor, Pred_elem}|Acc]);

encode([], Pred_elem, Kol_Povtor, Acc) ->
	[{Kol_Povtor, Pred_elem}|Acc].
	
encode_test() ->
	?assert(p10:encode([a,a,a,a,b,c,c,a,a,d,e,e,e,e]) =:= [{4,a},{1,b},{2,c},{2,a},{1,d},{4,e}]).

	