mutable struct Game{N}
    dimensions::NTuple{N, Int}
    variables::NTuple{N, Symbol}
    utilities::NTuple{N, Function}
    set_nneg::NTuple{N, Function}
    set_null::NTuple{N, Function}
end

function Game(dimensions::NTuple{N, Int}, variables::NTuple{N, Symbol}, utilities::NTuple{N, Function}) where N
    default_nneg(_) = 1
    default_null(_) = 0

    return Game{N}(
        dimensions,
        variables,
        utilities,
        ntuple(_ -> default_nneg, N),
        ntuple(_ -> default_null, N),
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

macro game(args...)
    vars = args[1:end-1]
    util = args[end]

    params = [var.args[1] for var in vars]
    dimensions = [var.args[2] for var in vars]
    symbols = [QuoteNode(var.args[1]) for var in vars]
    utilities = [esc(:(($(params...),) -> $e)) for e in util.args if e isa Expr]

    if length(vars) != length(utilities)
        error("Number of variables and utilities must be equal.")
    end

    return :(Game(
        tuple($(dimensions...)),
        tuple($(symbols...)),
        tuple($(utilities...))
    ))
end

macro strategy_set(game, var, block)
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

    nneg_lambda = :($var -> tuple($(nneg_exprs...)))
    null_lambda = :($var -> tuple($(null_exprs...)))

    quote
        game_set_nneg!($(esc(game)), $(QuoteNode(var)), $nneg_lambda)
        game_set_null!($(esc(game)), $(QuoteNode(var)), $null_lambda)
    end
end