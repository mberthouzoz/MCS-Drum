%%%-------------------------------------------------------------------
%%% @author MichaëlBerthouzoz - Marc Pellet - David Villa
%%% @copyright (C) 2016
%%% @doc
%%%
%%% @end
%%% Created : 10. avr. 2016 10:39
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
      render(Version, Tempo, Tracks);
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

render_tracks(_T, _Size) ->
  [render_tracks(Elem) || Elem <- _T].

render_tracks({TrackN, Instr, Measure}) ->
  Prefix = io_lib:format("(~B) ~s\t", [TrackN, Instr]),
  Grid = render_measure(Measure),
  [Prefix, Grid, $\n].


render_measure([P1,P2,P3,P4]) ->
  [$|, conv(P1), $|, conv(P2), $|, conv(P3), $|, conv(P4), $|].

conv(Pat) -> [render_c(C) || C <- Pat].

render_c(0) -> $-;
render_c(1) -> $x.


parse_measure(Data) ->
  parse_measure(Data, []).

parse_measure(Data, Acc) ->
  case Data of
    << A, B, C, D , Rest/binary>> when A < 2, B <2, C <2, D<2 -> parse_measure(Rest, [[A,B,C,D]| Acc]);
    << A, B, C, D , _/binary>> -> {parse_measure, bad_value, <<A, B, C, D>> };
    _ -> lists:reverse(Acc)
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
  {ok, parse_tracks(Data, [])}.

parse_tracks(Data, Acc) ->
  case Data of
    << TrackN:32/little, Size:8, Instr:Size/binary, Measure:16/binary, Rest/binary>> ->parse_tracks(Rest,  [{TrackN, binary_to_string(Instr), parse_measure(Measure)} | Acc]);
    _ -> lists:reverse(Acc)
  end.


render(Version, Tempo, Tracks) ->
  io:format("Saved with HW Version: ~s~nTempo: ~s~n~s",
    [Version, get_float(Tempo), render_tracks(Tracks, get_size(Tracks))]).


%% Get size for padding, if the first letter is capitalized -> 2 else 0
get_size([]) -> 0;
get_size([{_, Instr, _ } | Tracks]) ->
  case Instr of
    [F | _] when $A =< F, $Z =< F -> 2;
    _ -> get_size(Tracks)
  end.

%% Format the float. If 23.0 -> 23, 23.23 -> 23.23
get_float(Number) ->
  case abs(Number - trunc(Number)) of
    Gap when Gap < 0.0001 -> integer_to_list(trunc(Number));
    _ -> float_to_list(Number, [{decimals, 1}, compact])
  end.
