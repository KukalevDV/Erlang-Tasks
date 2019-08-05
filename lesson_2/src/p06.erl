-module(p06).
-export([is_palindrome/1]).

-include_lib("eunit/include/eunit.hrl").

is_palindrome(Sp) ->
	is_palindrome(Sp, p05:reverse(Sp)).

is_palindrome(Sp, Sp) ->
	true;
is_palindrome(_, _) ->
	false.

is_palindrome_test() ->
	?assert(p06:is_palindrome([1,2,3,2,1]) =:= true).
	
