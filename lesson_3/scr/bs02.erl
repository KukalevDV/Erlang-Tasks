-module(bs02).
-export([words/1]).

-include_lib("eunit/include/eunit.hrl").

words(Bin) ->
	p05:reverse(words(Bin, <<>>, [])).

words(<<" ", Rest/binary>>, Acc_word, Acc) ->
	words(Rest, <<>>, [Acc_word|Acc]);

words (<<C/utf8, Rest/binary>>, Acc_word, Acc) ->
	words(Rest, <<Acc_word/binary, C/utf8>>, Acc);
	
words(<<>>, Acc_word, Acc) ->
	[Acc_word|Acc].

words_test() ->
	 BinText = <<"Text with four words">>,
	?assert(bs02:words(BinText) =:= [<<"Text">>, <<"with">>, <<"four">>, <<"words">>]).
