-module(cache_server_SUITE).

-include_lib("common_test/include/ct.hrl").

-compile(export_all).

% ct:run_test([{suite, cache_server_SUITE}]). 

all() ->
	[
        test_create,
		test_insert,
		test_lookup,
		test_lookup_after_pause,
		test_lookup_after_long_pause,
		test_lookup_by_date
    ].


test_create(_Config) ->
	{ok, _} = cache_server:start_link(dima, [{drop_interval, 3}]).
	
test_insert(_Config) ->
	cache_server:start_link(dima, [{drop_interval, 3}]),
	ok = cache_server:insert(dima, 1, 1, 2).

test_lookup(_Config) ->
	cache_server:start_link(dima, [{drop_interval, 3}]),
	cache_server:insert(dima, 1, 1, 2),
	{ok, 1} = cache_server:lookup(dima, 1).

test_lookup_by_date(_Config) ->
	cache_server:start_link(dima, [{drop_interval, 3}]),
	cache_server:insert(dima, 1, 1, 2),
	DateFrom = {{2019,01,01},{00,00,00}},
	DateTo = calendar:local_time(),
	{ok, [1|[]]} = cache_server:lookup_by_date(dima, DateFrom, DateTo).		

test_lookup_after_pause(_Config) ->
	cache_server:start_link(dima, [{drop_interval, 3}]),
	cache_server:insert(dima, 1, 1, 1),
	timer:sleep(2000),
	{ok,undefined} = cache_server:lookup(dima, 1).	

test_lookup_after_long_pause(_Config) ->
	cache_server:start_link(dima, [{drop_interval, 1}]),
	cache_server:insert(dima, 1, 1, 1),
	timer:sleep(3000),
	0 = cache_server:count(dima).	