-module(bs04).
-export([decode/2]).

-include_lib("eunit/include/eunit.hrl").

decode(Json, VidParam) ->
	case VidParam of
		proplist -> json_to_value(Json, VidParam);
		map -> json_to_value(Json, VidParam);
		_ -> unknown
	end.

json_to_value(Json, VidParam) ->
	
	%% Раскладываем Json на отдельные значения и заносим в список
	Sp = value_to_list(Json, <<>>, 0, 0, []),
	
	case is_list(Sp) of
		
		%% Если список значений плучился
		true -> 
			case VidParam of
				proplist -> spisok_to_key_value(Sp, [], VidParam);
				_ ->	
					{_,Vid} = get_param_value(Json, 0),
					case Vid of
						ismap -> spisok_to_key_value(Sp, maps:new(), VidParam);
						    _ -> spisok_to_key_value(Sp, [], VidParam)
					end
			end;	
		
		%% Список не получился - значение было единичным
		false -> value_to_goodvalue(Sp)
	end.

%% Значение переводим в нужный формат
value_to_goodvalue(Json) ->
	Json2 = trimLR(Json),
	case Json2 of
		<<"true">> -> true;
		<<"false">> -> false;
		_ -> 
			case is_chislo(Json2) of
				true -> binary_to_integer(Json2);
				false -> 
					Value_2 = binary:replace(Json2, <<"'">>, <<>>, [global]),
					<<Value_2/binary>> 							  
			end	  
	end.

%% обрабатываем каждое значение из списка значений
spisok_to_key_value([H|T], Acc, VidParam) ->
	%%Определяем есть ли у значение пара ключ:значние или только ключ
	{Value_is_empty,_} = get_param_value(H, 0),
	
	case Value_is_empty of
		key_only -> spisok_to_key_value(T, [json_to_value(H, VidParam)|Acc], VidParam);
		key_and_value -> 
			Sp = binary:split(H, <<": ">>),
			[Key|[Value|_]] = Sp,
			case is_list(Acc) of
				false -> spisok_to_key_value(T, maps:put(value_to_goodvalue(Key), json_to_value(Value, VidParam), Acc), VidParam);
				_ -> spisok_to_key_value(T, [{value_to_goodvalue(Key), json_to_value(Value, VidParam)}|Acc], VidParam)
			end
	end;
	
spisok_to_key_value([], Acc, _) ->
	Acc.

%% Определяем есть или пара ключ:значение и является ли значение тоже списком 
get_param_value(<<C/utf8, R/binary>>, LevelSk)->
	case <<C/utf8>> of	
		<<"'">> when LevelSk == 1 -> get_param_value(R, LevelSk - 1); 
		<<"'">> when LevelSk == 0 -> get_param_value(R, LevelSk + 1); 
		_ when LevelSk == 1 -> get_param_value(R, LevelSk);
		<<"{">> -> {key_only, ismap}; 	
		<<"[">> -> {key_only, islist}; 	
		<<":">> -> {key_and_value, islist};
		_ -> get_param_value(R, LevelSk)
	end;

get_param_value(<<>>, _)->
	{key_only, islist}.

%% Раскладываем значение на список значений
value_to_list(<<C/utf8, R/binary>>, Acc, Level, LevelSk, AccSpis) ->
	case <<C/utf8>> of
		<<"'">> when LevelSk == 1 -> value_to_list(R, <<Acc/binary, C/utf8>>, Level, LevelSk - 1, AccSpis); 
		<<"'">> when LevelSk == 0 -> value_to_list(R, <<Acc/binary, C/utf8>>, Level, LevelSk + 1, AccSpis); 
		_ when LevelSk == 1 -> value_to_list(R, <<Acc/binary, C/utf8>>, Level, LevelSk, AccSpis);
		<<"{">> when Level == 0 -> value_to_list(R, Acc, Level + 1, LevelSk, AccSpis); 
		<<"{">> when Level > 0 -> value_to_list(R, <<Acc/binary, C/utf8>>, Level + 1, LevelSk, AccSpis); 
		<<"}">> when Level > 1 -> value_to_list(R, <<Acc/binary, C/utf8>>, Level - 1, LevelSk, AccSpis); 
		<<",">> when Level == 1 -> 	value_to_list(R, <<>>, Level, LevelSk, [trimLR(Acc)|AccSpis]);
		<<":">> when Level == 0 -> 	value_to_list(R, <<>>, Level, LevelSk, [trimLR(Acc)|AccSpis]);
		<<"}">> when Level == 1 -> [trimLR(Acc)|AccSpis];
		<<"[">> when Level == 0 -> value_to_list(R, Acc, Level + 1, LevelSk, AccSpis); 
		<<"[">> when Level > 0 -> value_to_list(R, <<Acc/binary, C/utf8>>, Level + 1, LevelSk, AccSpis); 
		<<"]">> when Level > 1 -> value_to_list(R, <<Acc/binary, C/utf8>>, Level - 1, LevelSk, AccSpis); 
		<<"]">> when Level == 1 -> 	[trimLR(Acc)|AccSpis];
		_ -> value_to_list(R, <<Acc/binary, C/utf8>>, Level, LevelSk, AccSpis)
	end;

value_to_list(<<>>, Acc, _, _, _) ->
	Acc.

%% Удаляем не печатные символы
trimLR(Value)->
	%%list_to_binary(string:trim(binary:bin_to_list(Value))).
	reverse(trimL(reverse(trimL(Value),<<>>)),<<>>).
	
%% Реверс - необходим для удаления непечатных символов
reverse(<<C/utf8, R/binary>>, Acc)->
	reverse(R, <<C/utf8, Acc/binary>>);

reverse(<<>>, Acc)->
	Acc.

%% Удаляем не печатные символы слева
trimL(<<C/utf8, R/binary>>)->
	if 
		<<C/utf8>> =/= <<"\r">> andalso <<C/utf8>> =/= <<"\n">> andalso <<C/utf8>> =/= <<" ">> -> <<C/utf8, R/binary>>;  
		true -> trimL(R)
	end;

trimL(<<>>)->
	<<>>.

%% Определяем является ли значение числом
is_chislo(Ch) ->
	is_chislo(Ch, 0).
	
is_chislo(<<C/utf8, R/binary>>, _) ->
	case <<C/utf8>> of
		<<"'">> -> is_chislo(<<>>, 0);
		_ -> is_chislo(R, 1)
	end;

is_chislo(<<>>, IsChislo) ->
	if 
		IsChislo == 0 -> false;
		true -> true
	end.


decode_test() ->
Json = <<"
 {
 'squadName': 'Super hero squad',
 'homeTown': 'Metro City',
 'formed': 2016,
 'secretBase': 'Super tower',
 'active': true,
 'members': [
 {
 'name': 'Molecule Man',
 'age': 29,
 'secretIdentity': 'Dan Jukes',
 'powers': [
 'Radiation resistance',
 'Turning tiny',
 'Radiation blast'
 ]
 },
 {
 'name': 'Madame Uppercut',
 'age': 39,
 'secretIdentity': 'Jane Wilson',
 'powers': [
 'Million tonne punch',
 'Damage resistance',
 'Superhuman reflexes'
 ]
 },
 {
 'name': 'Eternal Flame',
 'age': 1000000,
 'secretIdentity': 'Unknown',
 'powers': [
 'Immortality',
 'Heat Immunity',
 'Inferno',
 'Teleportation',
 'Interdimensional travel'
 ]
 }
 ]
 }
 ">>,
PropList = 
[{<<"squadName">>,<<"Super hero squad">>},
 {<<"homeTown">>,<<"Metro City">>},
 {<<"formed">>,2016},
 {<<"secretBase">>,<<"Super tower">>},
 {<<"active">>,true},
 {<<"members">>,
 [[{<<"name">>,<<"Molecule Man">>},
 {<<"age">>,29},
 {<<"secretIdentity">>,<<"Dan Jukes">>},
 {<<"powers">>,
 [<<"Radiation resistance">>,<<"Turning tiny">>,
 <<"Radiation blast">>]}],
 [{<<"name">>,<<"Madame Uppercut">>},
 {<<"age">>,39},
 {<<"secretIdentity">>,<<"Jane Wilson">>},
 {<<"powers">>,
 [<<"Million tonne punch">>,<<"Damage resistance">>,
 <<"Superhuman reflexes">>]}],
 [{<<"name">>,<<"Eternal Flame">>},
 {<<"age">>,1000000},
 {<<"secretIdentity">>,<<"Unknown">>},
 {<<"powers">>,
 [<<"Immortality">>,<<"Heat Immunity">>,<<"Inferno">>,
 <<"Teleportation">>,<<"Interdimensional travel">>]}]]}],

Map = 
#{<<"active">> => true,<<"formed">> => 2016,
 <<"homeTown">> => <<"Metro City">>,
 <<"members">> =>
 [#{<<"age">> => 29,<<"name">> => <<"Molecule Man">>,
 <<"powers">> =>
 [<<"Radiation resistance">>,<<"Turning tiny">>,
 <<"Radiation blast">>],
 <<"secretIdentity">> => <<"Dan Jukes">>},
 #{<<"age">> => 39,<<"name">> => <<"Madame Uppercut">>,
 <<"powers">> =>
 [<<"Million tonne punch">>,<<"Damage resistance">>,
 <<"Superhuman reflexes">>],
 <<"secretIdentity">> => <<"Jane Wilson">>},
 #{<<"age">> => 1000000,<<"name">> => <<"Eternal Flame">>,
 <<"powers">> =>
 [<<"Immortality">>,<<"Heat Immunity">>,<<"Inferno">>,
 <<"Teleportation">>,<<"Interdimensional travel">>],
 <<"secretIdentity">> => <<"Unknown">>}],
 <<"secretBase">> => <<"Super tower">>,
 <<"squadName">> => <<"Super hero squad">>},	

?assert(bs04:decode(Json, proplist) =:= PropList),
?assert(bs04:decode(Json, map) =:= Map).
