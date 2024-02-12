using JuMP
using MosekTools

_OPT_ATTRS = (MOI.Silent() => true,)
_DEFAULT_OPTIMIZER = optimizer_with_attributes(Mosek.Optimizer, _OPT_ATTRS...)

"""
    nash_equilibrium(payoffs::NTuple{1}; optimizer)

Compute the nash equilibrium for a two-player zero-sum game.

Returns:
    values, mixed strategies
"""
function nash_equilibrium(payoff; optimizer=_DEFAULT_OPTIMIZER)
    axis = axes(payoff, 1)

    model = Model(optimizer)
    @variable model v
    @variable model weight[axis] >= 0
    @objective model Min v
    c = @constraint model v .>= -payoff' * weight
    @constraint model sum(weight) == 1

    optimize!(model)

    (-value(v), value(v)), (value.(weight), dual.(c))
end