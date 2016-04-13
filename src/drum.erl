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

%% API
-export([render_file/1, decode_file/1, render_tracks/2, parse_measure/1, parse_header/1, binary_to_string/1, parse_tracks/1, render/3]).


render_file(_Arg0) ->
  erlang:error(not_implemented).

decode_file(_Arg0) ->
  erlang:error(not_implemented).

render_tracks(_A, _B) ->
  erlang:error(not_implemented).


parse_measure(_A) ->
  erlang:error(not_implemented).

parse_header(_Arg0) ->
  case _Arg0 of
    <<"SPLICE", _:64, Version:32/binary, Tempo:32/little-float, Rest/binary>> ->
      {ok, binary_to_string(Version), Tempo, Rest};
    Any -> {error, parse_header, Any}
  end.


binary_to_string(_Arg0) ->
  string:strip(binary_to_list(_Arg0), right, 0).

parse_tracks(_Arg0) ->
  erlang:error(not_implemented).

render(_Arg0, _Arg1, _Arg2) ->
  erlang:error(not_implemented).