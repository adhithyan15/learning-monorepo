% File: hello.erl
-module(hello_world).
-export([start/0]).

start() ->
    io:format("Hello, world!~n").