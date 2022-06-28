-module(coinbase).

-export([test/3]).

test(Currency, Target, Amount) ->
    Method = get,
    Ts = os:system_time(),
    Tsb = integer_to_binary(Ts),
    URL =
        <<"https://api.coinbase.com/v2/exchange-rates?currency=", Currency/binary, "&ts=",
            Tsb/binary>>,
    Headers = [{<<"Accept">>, <<"application/json">>}],
    Options = [],
    {ok, _StatusCode, _RespHeaders, ClientRef} = hackney:request(
        Method,
        URL,
        Headers,
        Options
    ),
    {ok, Body} = hackney:body(ClientRef),
    A = jsx:decode(Body),
    [{<<"data">>, [_, {_, R}]} | _] = A,
    V = proplists:get_value(<<Target/binary>>, R),
    io:format("URL: ~s~n", [URL]),
    E = 1 / list_to_float(binary_to_list(V)),
    {(E * Amount), V}.
