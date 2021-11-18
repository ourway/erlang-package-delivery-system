-module(helpers).
-export([chunk/2, filter/2, map/2]).

chunk(List, N) ->
    RevList = split_list(List, N),
    lists:foldl(fun(E, Acc) -> [lists:reverse(E) | Acc] end, [], RevList).

split_list(List, Max) ->
    element(
        1,
        lists:foldl(
            fun
                (E, {[Buff | Acc], C}) when C < Max ->
                    {[[E | Buff] | Acc], C + 1};
                (E, {[Buff | Acc], _}) ->
                    {[[E], Buff | Acc], 1};
                (E, {[], _}) ->
                    {[[E]], 1}
            end,
            {[], 0},
            List
        )
    ).

filter(F, [H | T]) ->
    case F(H) of
        true ->
            [H | filter(F, T)];
        false ->
            filter(F, T)
    end;
filter(_F, []) ->
    [].

map(F, [H | T]) ->
    [F(H) | map(F, T)];
map(_F, []) ->
    [].
