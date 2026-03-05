using Base.Iterators: product
using LinearAlgebra
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

"""Compute the nash equilibrium for a two-player zero-sum game."""
function zerosum_nash(payoff::AbstractMatrix; optimizer=_default_optimizer)
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

"""Computes the values and NE strategies for a two-player general-sum game"""
function generalsum_nash(us::NTuple{2, AbstractMatrix}; optimizer=_default_optimizer)
    m = Model(optimizer)

    nx, ny = size(us[1])
    @variable(m, xs[1:nx], lower_bound=0, upper_bound=1)
    @variable(m, ys[1:ny], lower_bound=0, upper_bound=1)
    @variable(m, w[i=1:2], lower_bound=minimum(us[i]), upper_bound=maximum(us[i]))

    @constraint(m, sum(xs) == 1)
    @constraint(m, sum(ys) == 1)

    @constraint(m, dot(xs, us[1], ys) + dot(xs, us[2], ys) >= sum(w))
    @constraint(m, (us[1] * ys)  .<= w[1])
    @constraint(m, (xs' * us[2]) .<= w[2])

    optimize!(m)

    tuple(value.(w)...), (value.(xs), value.(ys))
end

_subgame(payoff, actions) = map(a -> payoff(a...), product(actions...))

"""
    equilibrium(payoff, actions)

Compute the player equilibrium strategies in a subgame restricted to actions.
"""
function equilibrium(payoff::NTuple{2, Function}, actions::NTuple{2})
    subproblem = (_subgame(payoff[1], actions), _subgame(payoff[2], actions))
    generalsum_nash(subproblem)
end

function equilibrium(payoff::NTuple{1, Function}, actions::NTuple{2})
    subproblem = _subgame(only(payoff), actions)
    zerosum_nash(subproblem)
end