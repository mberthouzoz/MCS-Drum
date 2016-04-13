%%%-------------------------------------------------------------------
%%% @author Michaël
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. avr. 2016 10:39
%%%-------------------------------------------------------------------
-module(drum).
-author("Michaël").

-define(MAGIC, "SPLICE").


%% API
-export([render_file/1, decode_file/1, render_tracks/2, parse_measure/1, parse_header/1, binary_to_string/1, parse_tracks/1, render/3]).


render_file(F) ->
  IO = decode_file(F),
  case IO of
    {ok, Version, Tempo, Tracks} ->
      {ok, render(Version, Tempo, Tracks)};
    _ -> IO
  end.


decode_file(F) ->
  IO = file:read_file(F),
  case IO of
    {ok, Data} ->
      {ok, Version, Tempo, Rest} = parse_header(Data),
      {ok, Tracks} = parse_tracks(Rest),
      {ok, Version, Tempo, Tracks};
    _ -> IO
  end.

render_tracks(_A, _B) ->
    erlang:error(not_implemented).


parse_measure(Data) ->
  case Data of
    << A:4/binary, B:4/binary, C:4/binary, D:4/binary>> ->
      [binary_to_list(A),binary_to_list(B), binary_to_list(C), binary_to_list(D)];
    _ -> {error, parse_measure}
  end.


parse_header(Data) ->
  case Data of
    <<?MAGIC, _:64, Version:32/binary, Tempo:32/little-float, Rest/binary>> ->
      {ok, binary_to_string(Version), Tempo, Rest};
    Any -> {error, parse_header, Any}
  end.


binary_to_string(B) ->
  string:strip(binary_to_list(B), right, 0).

parse_tracks(Data) ->
  case Data of
    << TrackN:8, Size:32, Instr:Size/binary, Measure:16/binary>> -> {ok , [{TrackN, binary_to_string(Instr), parse_measure(Measure)}]};
    _ -> {ok, []}
  end.


render(Version, Tempo, Tracks) ->
  io_lib:format("Saved with HW Version: ~s~nTempo: ~s~n~s",
    [Version, get_float(Tempo), render_tracks(Tracks, get_size(Tracks))]).


%% Get size for padding, if the first letter is capitalized -> 2 else 0
get_size([]) -> 0;
get_size([{_, Instr, _ } | Tracks]) ->
  case Instr of
    [F | _] when $A =< F, $Z =< F -> 2;
    _ -> get_size(Tracks)
  end.

get_float(Number) ->
  case Number - trunc(Number) > 0 of
    true  -> float_to_list(Number, [{decimals, 3}, compact]);
    false -> float_to_list(Number, [{decimals, 0}])
  end.
