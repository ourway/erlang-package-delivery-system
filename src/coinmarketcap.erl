-module(coinmarketcap).

-export([test/0]).

-define(API_KEY, <<"51dd0efb-d25b-4b59-abb3-884a7a336135">>).

test() ->
    Method = get,
    URL = <<"https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest">>,
    Headers = [{<<"Accept">>, <<"application/json">>}, {<<"X-CMC_PRO_API_KEY">>, ?API_KEY}],
    Payload = <<"start=1&limit=5000&convert=GBP">>,
    Options = [],
    {ok, StatusCode, RespHeaders, ClientRef} = hackney:request(
        Method,
        URL,
        Headers,
        Payload,
        Options
    ),
    {ok, Body} = hackney:body(ClientRef).
