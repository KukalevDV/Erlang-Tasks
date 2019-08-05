-module(p04).
-export([len/1]).

-include_lib("eunit/include/eunit.hrl").

len (L) ->
	len(L,0).

len ([_|T], N) ->
	len(T,N+1);
len([],N) ->
	N.

len_test() ->
	?assert(p04:len([a,b,c,d]) =:= 4),
	?assert(p04:len([]) =:= 0).
