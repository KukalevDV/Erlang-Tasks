-module(bs03).
-export([split/2]).

-include_lib("eunit/include/eunit.hrl").

split(Bin, Sep) ->
	BinSep = list_to_binary(Sep),
	Size = byte_size(BinSep),
	split(Bin, BinSep, Size, <<>>, []).

split(Bin, Sep, Size, Word, Acc) ->
	case Bin of
		<<Sep:Size/binary, Rest/binary>> ->
			split(Rest, Sep, Size, <<>>, [Word|Acc]);
		<<C/utf8, Rest/binary>> ->
			split(Rest, Sep, Size, <<Word/binary, C/utf8>>, Acc);
		<<>> ->
			lists:reverse([Word|Acc])
	end.

split_test() ->
	 BinText = <<"Col1-:-Col2-:-Col3-:-Col4-:-Col5">>,
	?assert(bs03:split(BinText, "-:-") =:= [<<"Col1">>, <<"Col2">>, <<"Col3">>, <<"Col4">>, <<"Col5">>]).

