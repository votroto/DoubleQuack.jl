mutable struct Game{P, U}
    dimensions::NTuple{P, Int}
    variables::NTuple{P, Symbol}
    utilities::NTuple{U, Function}
    set_nneg::NTuple{P, Function}
    set_null::NTuple{P, Function}
end

function Game(dimensions::NTuple{P, Int}, variables::NTuple{P, Symbol}, utilities::NTuple{U, Function}) where {P, U}
    default_nneg(_) = 1
    default_null(_) = 0

    return Game{P, U}(
        dimensions,
        variables,
        utilities,
        ntuple(_ -> default_nneg, P),
        ntuple(_ -> default_null, P),
    )
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

function parse_game_params(args...)
    vars = args[1:end-1]
    util = args[end]

    params = [var.args[1] for var in vars]
    dims = [var.args[2] for var in vars]
    syms = [QuoteNode(var.args[1]) for var in vars]
    utils = [esc(:(($(params...),) -> $e)) for e in util.args if e isa Expr]

    dims, syms, utils
end

macro game(args...)
    dims, syms, utils = parse_game_params(args...)

    if (length(syms) != length(utils) && length(syms) != 2 && length(utils) != 1) || length(syms) <= 1
        error("General-sum games must have at least two variables and a matching number of utilities, while zero-sum two player games must have 2 and 1.")
    end

    return :(Game(($(dims...),), ($(syms...),), ($(utils...),)))
end

function __strategy_set(game, vars, bind, block)
    constr_expr(dotted, e1, e2) = dotted ? :(($e1 .- $e2)...) : :($e1 - $e2)

    exprs = block isa Expr && block.head == :block ? block.args : [block]

    nneg_exprs = Any[1]
    null_exprs = Any[0]

    for ex in exprs
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

    nneg_lambda = :($bind -> tuple($(nneg_exprs...)))
    null_lambda = :($bind -> tuple($(null_exprs...)))

    Expr(:block, [
        :(game_set_nneg!($(esc(game)), $(QuoteNode(var)), $nneg_lambda))
        for var in vars
    ]..., [
        :(game_set_null!($(esc(game)), $(QuoteNode(var)), $null_lambda))
        for var in vars
    ]...)
end

macro strategy_set(game, args...)
    if length(args) == 2 && args[2].head == :block
        __strategy_set(game, [args[1]], args[1], args[2])
    elseif length(args) >= 3 && args[end-1] == :as && args[end].args[1] == :in
        __strategy_set(game, args[1:end-2], args[end].args[2], args[end].args[3])
    else
        error("did not understand strategy set definition: $args")
    end
end