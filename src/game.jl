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
    utilities::NTuple{U, Function},
    set_nneg::NTuple{P, Function} = ntuple(_ -> (_ -> 1), P),
    set_null::NTuple{P, Function} = ntuple(_ -> (_ -> 0), P)
) where {P, U}
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

macro strategy_set(game, args...)
    vars, nneg_lambda, null_lambda = parse_cset(args)

    Expr(:block, [
        :(game_set_nneg!($(esc(game)), $(QuoteNode(var)), $nneg_lambda))
        for var in vars
    ]..., [
        :(game_set_null!($(esc(game)), $(QuoteNode(var)), $null_lambda))
        for var in vars
    ]...)
end

function split_array(arr, by)
    result = []
    sub = []

    for item in arr
        if item == by
            if !isempty(sub)
                push!(result, sub)
                sub = []
            end
        else
            push!(sub, item)
        end
    end
    if !isempty(sub)
        push!(result, sub)
    end

    return result
end


function __parse_strategy_set(bind, set)
    @show bind
    constr_expr(dotted, e1, e2) = dotted ? :(($e1 .- $e2)...) : :($e1 - $e2)

    @assert set isa Expr

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

function parse_cset(c)
    # kingdom for a pattern match!
    vars, bnd, set =
        if length(c) == 1 && c[1].head == :call && c[1].args[1] == :in && length(c[1].args) == 3 && c[1].args[2] isa Symbol
            [c[1].args[2]], c[1].args[2], c[1].args[3]
        elseif length(c) == 1 && c[1].head == :call && c[1].args[1] == :in && length(c[1].args) == 3 && c[1].args[2] isa Expr && c[1].args[2].head == :tuple
            c[1].args[2].args, first(c[1].args[2].args), c[1].args[3]
        elseif length(c) == 3 && c[2] == :as && c[3].head == :call && c[3].args[1] == :in && c[1].head == :tuple
            c[1].args, c[3].args[2], c[3].args[3]
        else
            error("Did not understand constraint $c")
        end
    nn, nu = __parse_strategy_set(bnd, set)

    vars, nn, nu
end

function parse_direct_constrs(syms, constr_arg)
    nneg_dict = Dict{Symbol, Any}()
    null_dict = Dict{Symbol, Any}()
    for c in split_array(constr_arg, :with)
        vars, nn, nu = parse_cset(c)
        for v in vars
            nneg_dict[v] = nn
            null_dict[v] = nu
        end
    end

    nneg_dict, null_dict
end

macro game(var_arg, util_arg, constr_arg...)
    @assert var_arg.head == :tuple

    params = [var.args[1] for var in var_arg.args]
    dims = [var.args[2] for var in var_arg.args]
    syms = [QuoteNode(var.args[1]) for var in var_arg.args]
    utils = [esc(:(($(params...),) -> $e)) for e in util_arg.args if e isa Expr]
    nn, nu = parse_direct_constrs(params, constr_arg)

    @show nneg_tuple = ntuple(i -> get(nn, params[i], :(_ -> 1)), length(syms))
    @show null_tuple = ntuple(i -> get(nu, params[i], :(_ -> 0)), length(syms))


    if (length(syms) != length(utils) && length(syms) != 2 && length(utils) != 1) || length(syms) <= 1
        error("General-sum games must have at least two variables and a matching number of utilities, while zero-sum two player games must have 2 and 1.")
    end

    return :(Game(($(dims...),), ($(syms...),), ($(utils...),), ($(nneg_tuple...),), ($(null_tuple...),)))
end