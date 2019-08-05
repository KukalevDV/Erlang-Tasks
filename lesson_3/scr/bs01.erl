-module(bs01).
-export([first_word/1]).

-include_lib("eunit/include/eunit.hrl").

first_word(Bin) ->
	first_word(Bin, <<>>).

first_word(<<" ", _Rest/binary>>, Acc) ->
	Acc;
	
first_word(<<C/utf8, Rest/binary>>, Acc) ->
	first_word(Rest, <<Acc/binary, C/utf8>>);

first_word(<<>>, Acc) ->
	Acc.

first_word_test() ->
	BinText = <<"Some text">>,
	?assert(bs01:first_word(BinText) =:= <<"Some">>).