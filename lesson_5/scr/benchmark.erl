-module(benchmark).
-export([bench/0
		, create_map/0
		, create_proplist/0
		, create_dict/0
		, create_prdict/0
		, create_ets/0
		, update_map/1
		, update_dict/1
		, update_prdict/0
		, update_ets/1
		, get_map/1
		, get_proplist/1
		, get_dict/1
		, get_prdict/0
		, get_ets/1
		]).

bench() ->
	{Time1, Map} = timer:tc(benchmark, create_map, []),
	io:write({Time1, create_map}), io:nl(),
	
	{Time2, PropList} = timer:tc(benchmark, create_proplist, []),
	io:write({Time2, create_proplist}), io:nl(),
	
	{Time3, Dict} = timer:tc(benchmark, create_dict, []),
	io:write({Time3, create_dist}), io:nl(),
	
	{Time4, _} = timer:tc(benchmark, create_prdict, []),
	io:write({Time4, create_prdict}), io:nl(),
	
	{Time5, Ets} = timer:tc(benchmark, create_ets, []),
	io:write({Time5, create_ets}), io:nl(),

	{Time6, _} = timer:tc(benchmark, update_map, [Map]),
	io:write({Time6, update_map}), io:nl(),
	
	{Time7, _} = timer:tc(benchmark, update_dict, [Dict]),
	io:write({Time7, update_dist}), io:nl(),
	
	{Time8, _} = timer:tc(benchmark, update_prdict, []),
	io:write({Time8, update_prdict}), io:nl(),
	
	{Time9, _} = timer:tc(benchmark, update_ets, [Ets]),
	io:write({Time9, update_ets}), io:nl(),	

	{Time11, _} = timer:tc(benchmark, get_map, [Map]),
	io:write({Time11, get_map}), io:nl(),
	
	{Time16, _} = timer:tc(benchmark, get_match_map, [Map]),
	io:write({Time16, get_match_map}), io:nl(),
	
	{Time12, _} = timer:tc(benchmark, get_proplist, [PropList]),
	io:write({Time12, get_proplist}), io:nl(),
	
	{Time13, _} = timer:tc(benchmark, get_dict, [Dict]),
	io:write({Time13, get_dist}), io:nl(),
	
	{Time14, _} = timer:tc(benchmark, get_prdict, []),
	io:write({Time14, get_prdict}), io:nl(),
	
	{Time15, Ets} = timer:tc(benchmark, get_ets, [Ets]),
	io:write({Time15, get_ets}), io:nl(),

	ets:delete(dd),
	endl.

%--------------------------------------

get_match_map(KV)->
	get_match_map(KV, 10000).
get_match_map(KV, 0)->
	KV;
get_match_map(KV, N)->
	#{N := _} = KV,
	get_match_map(KV, N-1).


%--------------------------------------

get_map(KV)->
	get_map(KV, 10000).
get_map(KV, 0)->
	KV;
get_map(KV, N)->
	maps:get(N, KV),
	get_map(KV, N-1).

get_proplist(KV)->
	get_proplist(KV, 10000).
get_proplist(KV, 0)->
	KV;
get_proplist(KV, N)->
	proplists:get_value(N, KV),
	get_proplist(KV, N-1).

get_dict(KV)->
	get_dict(KV, 10000).
get_dict(KV, 0)->
	KV;
get_dict(KV, N)->
	dict:fetch(N, KV),
	get_dict(KV, N-1).

get_prdict()->
	get_prdist(10000).
get_prdist(0)->
	get_prdist;
get_prdist(N)->
	%get(N),
	get_prdist(N-1).

get_ets(KV)->
	get_ets(KV, 10000).
get_ets(KV, 0)->
	KV;
get_ets(KV, N)->
	ets:lookup(KV, N),
	get_ets(KV, N-1).


%--------------------------------------

update_map(KV)->
	update_map(KV, 10000).
update_map(KV, 0)->
	KV;
update_map(KV, N)->
	update_map(maps:put(N, N+1, KV), N-1).
	
update_dict(KV)->
	update_dict(KV, 10000).
update_dict(KV, 0)->
	KV;
update_dict(KV, N)->
	update_dict(dict:store(N, N+1, KV), N-1).

update_prdict()->
	update_prdist(10000).
update_prdist(0)->
	update_prdist;
update_prdist(N)->
	put(N, N),
	update_prdist(N-1).

update_ets(KV)->
	update_ets(KV, 10000).
update_ets(KV, 0)->
	KV;
update_ets(KV, N)->
	ets:insert(KV, {N, N+1}),
	update_ets(KV, N-1).

%--------------------------------------

create_map()->
	create_map(maps:new(), 10000).
create_map(KV, 0)->
	KV;
create_map(KV, N)->
	create_map(maps:put(N, N, KV), N-1).

create_proplist()->
	create_proplist([], 10000).
create_proplist(KV, 0)->
	KV;
create_proplist(KV, N)->
	create_proplist([N|KV], N-1).

create_dict()->
	create_dict(dict:new(), 10000).
create_dict(KV, 0)->
	KV;
create_dict(KV, N)->
	create_dict(dict:append(N, N, KV), N-1).

create_prdict()->
	create_prdist(10000).
create_prdist(0)->
	create_prdist;
create_prdist(N)->
	put(N, N),
	create_prdist(N-1).

create_ets()->
	create_ets(ets:new(dd, [named_table]), 10000).
create_ets(KV, 0)->
	KV;
create_ets(KV, N)->
	ets:insert(KV, {N, N}),
	create_ets(KV, N-1).