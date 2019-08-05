-module(toppage_h).

-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	HasBody = cowboy_req:has_body(Req0),
	Req = maybe_echo(Method, HasBody, Req0),
	{ok, Req, Opts}.	

maybe_echo(<<"POST">>, true, Req0) ->
	
	try
		{ok, Data, Req} = cowboy_req:read_body(Req0),
		DataN = jsx:decode(Data),
		Action = proplists:get_value(<<"action">>, DataN),

		case Action of
			<<"insert">> -> 
				Key = proplists:get_value(<<"key">>, DataN),
				Value = proplists:get_value(<<"value">>, DataN),
				cache_server:insert(dima, Key, Value, 60),			
				cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain; charset=utf-8">>}, <<"{\"result\":\"ok\"}">>, Req);	
			
			<<"lookup">> -> 
				Key = proplists:get_value(<<"key">>, DataN),
				Res = cache_server:lookup(dima, Key),

				case Res of
					{ok, Otvet} -> 
						OtvetJs = jsx:encode([{<<"result">>, Otvet}]),
						cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain; charset=utf-8">>}, OtvetJs, Req);
					_ -> cowboy_req:reply(400, [], <<"Missing body.">>, Req)
				end;
							
			<<"lookup_by_date">> -> 
				DateFrom = proplists:get_value(<<"date_from">>, DataN), 
				DateTo = proplists:get_value(<<"date_to">>, DataN), 
				
				DateFrom2 = parse_date(DateFrom),
				DateTo2 = parse_date(DateTo),

				Res = cache_server:lookup_by_date(dima, DateFrom2, DateTo2),
				%{ok,[{1,1},{3,3},{4,4},{2,2}]}
				
				case Res of
					{ok, Otvet} -> 
						OtvetJs = recurs_otvet(Otvet, []),
						OtvetJs2 = jsx:encode([{<<"result">>,OtvetJs}]),
						cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain; charset=utf-8">>}, OtvetJs2, Req);
					_ -> cowboy_req:reply(400, [], <<"Missing body.">>, Req)
				end;

			_ -> cowboy_req:reply(400, [], <<"Missing body.">>, Req)				
		end
	catch
		_Ms -> cowboy_req:reply(400, [], <<"Error.">>, Req0)
	end;	


maybe_echo(<<"POST">>, false, Req) ->
	cowboy_req:reply(400, [], <<"Missing body.">>, Req);

maybe_echo(_, _, Req) ->
	cowboy_req:reply(405, Req).

parse_date(Date) ->
	parse_date(Date, <<>>,<<>>,<<>>,<<>>,<<>>,<<>>,1).

recurs_otvet([H|T], Acc) ->
	{Key, Value} = H,
	recurs_otvet(T, [[{<<"key">>, Key},{<<"value">>, Value}]|Acc]);
	
recurs_otvet([], Acc) ->
	Acc.


parse_date(<<C/utf8, R/binary>>, God, Mes, Den, Ch, Min, Sec, Vid) ->
	case <<C/utf8>> of
		
		<<"/">> -> parse_date(R, God, Mes, Den, Ch, Min, Sec, Vid+1);
		<<" ">> -> parse_date(R, God, Mes, Den, Ch, Min, Sec, Vid+1);
		<<":">> -> parse_date(R, God, Mes, Den, Ch, Min, Sec, Vid+1);
		_ -> 
			case Vid of
				1 -> parse_date(R, <<God/binary, C/utf8>>, Mes, Den, Ch, Min, Sec, Vid);
				2 -> parse_date(R, God, <<Mes/binary, C/utf8>>, Den, Ch, Min, Sec, Vid);
				3 -> parse_date(R, God, Mes, <<Den/binary, C/utf8>>, Ch, Min, Sec, Vid);
				4 -> parse_date(R, God, Mes, Den, <<Ch/binary, C/utf8>>, Min, Sec, Vid);
				5 -> parse_date(R, God, Mes, Den, Ch, <<Min/binary, C/utf8>>, Sec, Vid);
				6 -> parse_date(R, God, Mes, Den, Ch, Min, <<Sec/binary, C/utf8>>, Vid)
			end
	end;

parse_date(<<>>, God, Mes, Den, Ch, Min, Sec, _) ->
	GodN = list_to_integer(binary_to_list(God)),	
	MesN = list_to_integer(binary_to_list(Mes)),	
	DenN = list_to_integer(binary_to_list(Den)),	
	ChN = list_to_integer(binary_to_list(Ch)),	
	MinN = list_to_integer(binary_to_list(Min)),	
	SecN = list_to_integer(binary_to_list(Sec)),	
	{{GodN,MesN,DenN},{ChN,MinN,SecN}}.
		
 	
