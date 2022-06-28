-module(bsearch).
-export([search/2]).
search(Nums, Target) ->
    search(list_to_tuple(Nums), Target, 0, length(Nums)-1).

search(_Nums, _Target, Low, High) when High < Low ->
    -1;
search(Nums, Target, Low, High) ->
    Mid = (Low + High) div 2,
    MidVal = element(Nums, Mid),
    case Target < MidVal of
        true ->
            search(Nums, Target, Low, Mid-1);
        false ->
            case Target == MidVal of
                true ->
                    Mid;
                false ->
                    search(Nums, Target, Mid+1, High)
            end
    end.
