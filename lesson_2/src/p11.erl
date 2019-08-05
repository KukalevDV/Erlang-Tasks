-module(p11).
-export([encode_modified/1]).

-include_lib("eunit/include/eunit.hrl").

encode_modified(L) ->
	p05:reverse(encode_modified(L, nil, 0, [])).

encode_modified([H|T], H, Kol_Povtor, Acc) ->
	encode_modified(T, H, Kol_Povtor + 1, Acc);

encode_modified([H|T], nil, _, Acc) ->
	encode_modified(T, H, 1, Acc);

encode_modified([H|T], Pred_elem, 1, Acc) ->
	encode_modified(T, H, 1,  [Pred_elem|Acc]);

encode_modified([H|T], Pred_elem, Kol_Povtor, Acc) ->
	encode_modified(T, H, 1,  [{Kol_Povtor, Pred_elem}|Acc]);

encode_modified([], Pred_elem, 1, Acc) ->
	[Pred_elem|Acc];

encode_modified([], Pred_elem, Kol_Povtor, Acc) ->
	[{Kol_Povtor, Pred_elem}|Acc].

encode_modified_test() ->
	?assert(p11:encode_modified([a,a,a,a,b,c,c,a,a,d,e,e,e,e]) =:= [{4,a},b,{2,c},{2,a},d,{4,e}]).


	