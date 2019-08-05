%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(lesson_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/api/cache_server", toppage_h, []}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
		env => #{dispatch => Dispatch}
	}),
	cache_server:start_link(dima, [{drop_interval, 3600}]),
	lesson_sup:start_link().

stop(_State) ->
	ok.
