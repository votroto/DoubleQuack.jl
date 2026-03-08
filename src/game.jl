mutable struct Game{P, U}
    dimensions::NTuple{P, Int}
    variables::NTuple{P, Symbol}
    utilities::NTuple{U, Function}
    set_nneg::NTuple{P, Function}
    set_null::NTuple{P, Function}
end

function Game(
    dimensions::NTuple{P, Int},
    variables::NTuple{P, Symbol},
    utilities::NTuple{U, Function}
) where {P, U}
    set_nneg = ntuple(_ -> (_ -> 1), P)
    set_null  = ntuple(_ -> (_ -> 0), P)
    return Game{P, U}(dimensions, variables, utilities, set_nneg, set_null)
end

function tuple_set_idx(original::NTuple{N, Function}, elem::Function, idx) where {N}
    ntuple(i -> i == idx ? elem : original[i], N)
end

function game_get_player_id_by_var(game, var_name)
    player_id = findfirst(==(var_name), game.variables)
    if isnothing(player_id)
        error("No player with variable $var_name.")
    end
    player_id
end

function game_set_nneg!(game, var_name::Symbol, nneg)
    pid = game_get_player_id_by_var(game, var_name)
    game.set_nneg = tuple_set_idx(game.set_nneg, nneg, pid)
end

function game_set_null!(game, var_name::Symbol, null)
    pid = game_get_player_id_by_var(game, var_name)
    game.set_null = tuple_set_idx(game.set_null, null, pid)
end

function __parse_strategy_set(bind, set::Expr)
    constr_expr(dotted, e1, e2) = dotted ? :(($e1 .- $e2)...) : :($e1 - $e2)

    nneg_exprs = Any[1]
    null_exprs = Any[0]

    if set.head == :block
        for ex in set.args
            ex isa LineNumberNode && continue

            if !(ex isa Expr && ex.head == :call)
                error("Expected comparison expression, got $ex")
            end

            op, lhs, rhs = ex.args
            dotted = op isa Symbol && startswith(String(op), ".")
            baseop = dotted ? Symbol(String(op)[2:end]) : op

            if baseop == :(>=)
                push!(nneg_exprs, constr_expr(dotted, lhs, rhs))
            elseif baseop == :(<=)
                push!(nneg_exprs, constr_expr(dotted, rhs, lhs))
            elseif baseop == :(==)
                push!(null_exprs, constr_expr(dotted, lhs, rhs))
            else
                error("Unsupported constraint: $ex.")
            end
        end
    elseif set.head == :vect && length(set.args) == 2
        lo, hi = set.args
        push!(nneg_exprs, :(($bind .- $(esc(lo)))...))
        push!(nneg_exprs, :(($(esc(hi)) .- $bind)...))
    else
        error("Did not understand strategy set definition.")
    end

    nneg_lambda = :($bind -> tuple($(nneg_exprs...)))
    null_lambda = :($bind -> tuple($(null_exprs...)))

    nneg_lambda, null_lambda
end

function __strategy_set(vinset::Expr)
    # kingdom for a pattern match!
    @assert (vinset.head == :call && vinset.args[1] == :in && length(vinset.args) == 3) "Did not understand constraint $vinset"
    _in, _vs, _set = vinset.args
    vars, bnd, set =
        if _vs isa Symbol
            [_vs], _vs, _set
        elseif _vs isa Expr && _vs.head == :tuple
            _vs.args, :fakevar, _set
        else
            error("Could not parse variables in $vinset")
        end
    nn, nu = __parse_strategy_set(bnd, set)

    vars, nn, nu
end

function __strategy_set(vars, _as, vinset::Expr)
    @assert (_as == :as && vinset.head == :call && vinset.args[1] == :in && vars.head == :tuple) "Did not understand constraint $vars $_as $vinset"
    vs, bnd, set = vars.args, vinset.args[2], vinset.args[3]
    nn, nu = __parse_strategy_set(bnd, set)

    vs, nn, nu
end

macro strategy_set(game, args...)
    vars, nneg_lambda, null_lambda = __strategy_set(args...)

    Expr(:block, [
        :(game_set_nneg!($(esc(game)), $(QuoteNode(var)), $nneg_lambda))
        for var in vars
    ]..., [
        :(game_set_null!($(esc(game)), $(QuoteNode(var)), $null_lambda))
        for var in vars
    ]...)
end

macro game(var_arg, util_arg)
    @assert var_arg.head == :tuple

    params = [var.args[1] for var in var_arg.args]
    dims = [var.args[2] for var in var_arg.args]
    syms = [QuoteNode(var.args[1]) for var in var_arg.args]
    utils = [esc(:(($(params...),) -> $e)) for e in util_arg.args if e isa Expr]

    @assert length(syms) >= 1 "Games must have at least two variables"
    @assert (length(syms) == length(utils) || length(syms) == 2 && length(utils) == 1) "General-sum games must have the same number of variables and utilities, while zero-sum two-player games must have 2 and 1."

    return :(Game(($(dims...),), ($(syms...),), ($(utils...),)))
end