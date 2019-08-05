-module(cache).

-export([create/1]).
-export([insert/4]).
-export([lookup/2]).
-export([lookup_by_date/3]).
-export([delete_obsolete/1]).
-export([count/1]).

-include_lib("stdlib/include/ms_transform.hrl").

-record(keyvalue, {key, value, time_actual, time_create}).

create(TableName) ->
	ets:new(TableName, [named_table, {keypos, #keyvalue.key}]),
	ok.
					   

insert(TableName, Key, Value, IntervalLive) ->
	ets:insert(TableName, #keyvalue{key = Key
		, value = Value
		, time_actual = calendar:datetime_to_gregorian_seconds(calendar:local_time()) + IntervalLive
		, time_create = calendar:datetime_to_gregorian_seconds(calendar:local_time())}), 
	ok.
	

lookup_by_date(TableName, DateFrom, DateTo) ->
	SecondsFrom = calendar:datetime_to_gregorian_seconds(DateFrom),
	SecondsTo = calendar:datetime_to_gregorian_seconds(DateTo),
	MS = ets:fun2ms(fun(#keyvalue{key = Key, value = Value, time_create=TimeCreate}) when TimeCreate >= SecondsFrom, TimeCreate =< SecondsTo -> {Key, Value} end), 
	ets:select(TableName, MS).
	

lookup(TableName, Key) ->
	TekTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	MS = ets:fun2ms(fun(#keyvalue{key=Key2, value = Value, time_actual=TimeActual}) when Key =:= Key2, TimeActual >= TekTime -> Value end), 
	SpValue = ets:select(TableName, MS),
	case SpValue of
		[] -> <<"undefined">>;
		[H] -> H
	end.	


delete_obsolete(TableName) ->
    TekTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	MS = ets:fun2ms(fun(#keyvalue{time_actual=TimeActual}) when TimeActual < TekTime -> true end), 
	ets:select_delete(TableName, MS).	

count(TableName) ->
	ets:info(TableName, size).
