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

function _parse_strategy_set(bind, set::Expr)
    _undot(s) = startswith(s, ".") ? (true, Symbol(s[2:end])) : (false, Symbol(s))
    _constr(dotted, lhs, rhs) = dotted ? :(($lhs .- $rhs)...) : :($lhs - $rhs)

    nneg_exprs = Any[1]
    null_exprs = Any[0]

    if Meta.isexpr(set, :block)
        for ex in set.args
            if (ex isa LineNumberNode)
                continue
            end
            if !(Meta.isexpr(ex, :call))
                error("Expected a comparison expression, got: $ex")
            end

            dotted, base = _undot(String(ex.args[1]))
            lhs, rhs     = ex.args[2], ex.args[3]

            if base == :(>=)
                push!(nneg_exprs, _constr(dotted, lhs, rhs))
            elseif base == :(<=)
                push!(nneg_exprs, _constr(dotted, rhs, lhs))
            elseif base == :(==)
                push!(null_exprs, _constr(dotted, lhs, rhs))
            else
                error("Unsupported constraint operator '$base' in: $ex")
            end
        end

    elseif Meta.isexpr(set, :vect) && length(set.args) == 2
        lo, hi = set.args
        push!(nneg_exprs, :(($bind .- $(esc(lo)))...))
        push!(nneg_exprs, :(($(esc(hi)) .- $bind)...))

    else
        error("Could not parse strategy set: $set")
    end

    nneg_lambda = :($bind -> tuple($(nneg_exprs...)))
    null_lambda = :($bind -> tuple($(null_exprs...)))
    nneg_lambda, null_lambda
end

function _strategy_set(vinset::Expr)
    if !(Meta.isexpr(vinset, :call, 3) && vinset.args[1] == :in)
        error("Expected `var in set`, got: $vinset")
    end

    _, vs_expr, set = vinset.args

    if vs_expr isa Symbol
        nn, nu = _parse_strategy_set(vs_expr, set)
        return [vs_expr], nn, nu
    elseif Meta.isexpr(vs_expr, :tuple)
        nn, nu = _parse_strategy_set(:_bind, set)
        return vs_expr.args, nn, nu
    else
        error("Could not parse variable(s) in: $vinset")
    end
end

function _strategy_set(vars_expr::Expr, as_kw::Symbol, vinset::Expr)
    if !(as_kw == :as && Meta.isexpr(vars_expr, :tuple) && Meta.isexpr(vinset, :call, 3) && vinset.args[1] == :in)
        error("Expected `(vars...) as bind in set`, got: $vars_expr $as_kw $vinset")
    end

    _, bind, set = vinset.args
    nn, nu = _parse_strategy_set(bind, set)
    vars_expr.args, nn, nu
end


"""
    @strategy_set game var begin
        constraint₁
        constraint₂
        ...
    end
    @strategy_set game var [lo, hi]
    @strategy_set game (var₁, var₂, ...) as bind in begin ... end

Attach a strategy set (feasible region) to one or more players in `game`.

The constraint block may contain any combination of:
- `expr >= rhs` — non-negativity constraint (`expr - rhs ≥ 0`)
- `expr <= rhs` — non-negativity constraint (`rhs - expr ≥ 0`)
- `expr == rhs` — equality constraint (`expr - rhs = 0`)

Dotted broadcast forms (`.>=`, `.<=`, `.==`) are also supported and are
splatted into element-wise constraints.

The shorthand `[lo, hi]` form is equivalent to `var .>= lo; var .<= hi`.

When multiple players share the same constraint structure, use the `as` form
to name the lambda parameter explicitly and apply it to all listed variables at
once.

# Examples

**Box** strategy set using the shorthand range form:
```julia
@strategy_set g x in [-1, 1]
```

**Shared** constraint applied to multiple players at once:
```julia
@strategy_set g (x, y) as v in begin
    v .>= 0
    sum(v) == 1
end
```
"""
macro strategy_set(game, args...)
    vars, nneg_lambda, null_lambda = _strategy_set(args...)

    Expr(:block,
        [:(game_set_nneg!($(esc(game)), $(QuoteNode(v)), $nneg_lambda)) for v in vars]...,
        [:(game_set_null!($(esc(game)), $(QuoteNode(v)), $null_lambda)) for v in vars]...
    )
end


"""
    @game (var₁{dim₁}, var₂{dim₂}, ...) begin
        utility₁(var₁, var₂, ...)
        utility₂(var₁, var₂, ...)
        ...
    end

Construct a continuous `Game` from a tuple of named vector variables and a
block of utility functions.

Each variable declaration `var{dim}` introduces a player whose strategy is a
vector of length `dim`. The utility block must contain one expression per
player (general-sum), or exactly one expression for a two-player zero-sum game
— in which case the second player's utility is taken to be its negation.

All variables are in scope as positional arguments inside every utility
expression.
"""
macro game(var_arg, util_arg)
    if !(Meta.isexpr(var_arg, :tuple) && Meta.isexpr(util_arg, :block))
        error("Game arguments must be a tuple of variables followed by a block of utilities.")
    end

    params = [v.args[1] for v in var_arg.args]
    dims   = [v.args[2] for v in var_arg.args]
    syms   = [QuoteNode(p) for p in params]
    utils  = [esc(:(($(params...),) -> $e)) for e in util_arg.args if e isa Expr]

    nv, nu = length(syms), length(utils)
    if !(nv >= 1 && (nv == nu || nv == 2 && nu == 1))
        error("General-sum games need one utility per variable; zero-sum two-player games need exactly one utility.")
    end

    :(Game(($(dims...),), ($(syms...),), ($(utils...),)))
end