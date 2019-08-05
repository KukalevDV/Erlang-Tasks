-module(cache_server).

-behaviour(gen_server).

-export([start_link/2]).
-export([insert/4]).
-export([lookup/2]).
-export([lookup_by_date/3]).
-export([count/1]).

%-export([test/0]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).

-include_lib("stdlib/include/ms_transform.hrl").

-record(state, {timer=timer, drop_interval = 3600, table_name}).

%test() ->
	
%	cache_server:start_link(dima, [{drop_interval, 3}]).
	
	%cache_server:start_link(dima, [{drop_interval, 30}]),
	%cache_server:insert(dima, 1, 1, 60),
	%cache_server:insert(dima, 2, 2, 60),
	%cache_server:insert(dima, 3, 3, 60),
	%cache_server:insert(dima, 4, 4, 60),
	%cache_server:count(dima).
	%DateFrom = {{2019,01,01},{00,00,00}},
	%DateTo = {{2019,01,02},{00,00,00}},
	%cache_server:lookup_by_date(dima, DateFrom, DateTo).
	%Res = cache_server:lookup(dima, 1),
	%Res.
		

%%-------------------------


get_drop_interval([], IntervalDefault) ->
	IntervalDefault;


get_drop_interval([H|T], IntervalDefault) ->
	case H of
		{drop_interval, Interval} -> Interval;
		_ -> get_drop_interval(T, IntervalDefault)
	end.


%%-------------------------


start_link(TableName, Param) ->
	DropInterval = get_drop_interval(Param, 3600), 
	gen_server:start_link({local, TableName}, ?MODULE, [TableName, DropInterval], []).


insert(TableName, Key, Value, IntervalLive) ->
	gen_server:call(TableName, {insert, TableName, Key, Value, IntervalLive}).


lookup(TableName, Key)->
	gen_server:call(TableName, {lookup, TableName, Key}).


lookup_by_date(TableName, DateFrom, DateTo)->
	gen_server:call(TableName, {lookup_by_date, TableName, DateFrom, DateTo}).


count(TableName)->
	gen_server:call(TableName, {count, TableName}).

%%-------------------------

handle_call({count, TableName}, _, State) ->
	try
		Count = cache:count(TableName),
		{reply, Count, State}
	catch
		Ms -> {reply, {error, Ms}, State}
	end;


handle_call({insert, TableName, Key, Value, IntervalLive}, _, State) ->
	try
		cache:insert(TableName, Key, Value, IntervalLive),
		{reply, ok, State}
	catch
		Ms -> {reply, {error, Ms}, State}
	end;


handle_call({lookup_by_date, TableName, DateFrom, DateTo}, _, State) ->
	try
		Value = cache:lookup_by_date(TableName, DateFrom, DateTo),
		{reply, {ok, Value}, State}
	catch
		Ms -> {reply, {error, Ms}, State}
	end;


handle_call({lookup, TableName, Key}, _, State) ->
	try
		Value = cache:lookup(TableName, Key),
		{reply, {ok, Value}, State}
	catch
		Ms -> {reply, {error, Ms}, State}
	end.


handle_info({drop_interval_first, DropInterval}, State) ->
  	Timer = erlang:send_after(DropInterval, self(), drop_interval),
  	{noreply, State#state{timer = Timer}};


handle_info(drop_interval, State) ->
	try
	  	erlang:cancel_timer(State#state.timer),
		cache:delete_obsolete(State#state.table_name)
	catch
		_ -> error
	end,	
	Timer = erlang:send_after(State#state.drop_interval, self(), drop_interval),
	{noreply, State#state{timer = Timer}}.
	

init(_Arg) ->
	case _Arg of
		[TableName|[DropInterval|_]] ->
			try
				cache:create(TableName),
				self() ! {drop_interval_first, DropInterval * 1000},
				{ok, #state{timer = timer, drop_interval = DropInterval * 1000, table_name = TableName}}
			catch    
   				_ -> ignore
			end;
		_ -> ignore
	end.


handle_cast(_, _) ->
    {noreply, ok}.