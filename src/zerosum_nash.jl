using JuMP
using Gurobi

const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    # Reuse environment between solves
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
    return
end

_default_optimizer() = Gurobi.Optimizer(GRB_ENV_REF[])

"""
    nash_equilibrium(payoffs::NTuple{1}; optimizer)

Compute the nash equilibrium for a two-player zero-sum game.

Returns:
    values, mixed strategies
"""
function nash_equilibrium(payoff; optimizer=_default_optimizer)
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