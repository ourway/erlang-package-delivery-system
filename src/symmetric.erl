-module(symmetric).

-export([encrypt_0/2, pad/0]).

pad() ->
	"5Zg3gSwezToDbJc/JqAu2UE6TSV89Opq0LhBhQIB/VWZCN0LdClN+KNzmU2MIIoC".

encrypt_0([H | T], [H1 | T1]) ->
	[H bxor H1 | encrypt_0(T, T1)];
encrypt_0(_, []) ->
	[].
