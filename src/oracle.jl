using JuMP
using Gurobi

function feasible_init_one(
    dom_nneg::Function,
    dom_null::Function,
    dim::Int;
    optimizer=_default_optimizer
)
    m = Model(optimizer)
    @variable(m, x[1:dim])
    @constraint(m, dom_nneg(x) .>= 0)
    @constraint(m, dom_null(x) .== 0)

    optimize!(m)

    [tuple(value.(x)...)]
end

function best_response(
    payoff::Function,
    dom_nneg::Function,
    dom_null::Function,
    start;
    dim=length(start),
    optimizer=_default_optimizer
)
    m = Model(optimizer)
    @variable(m, x[1:dim])
    @constraint(m, dom_nneg(x) .>= 0)
    @constraint(m, dom_null(x) .== 0)
    @objective(m, Max, payoff(x))

    set_start_value.(x, start)
    optimize!(m)

    if JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(x)...)
    else
        NaN
    end
end

function feasible_init(
    dom_nneg::NTuple{N,Function},
    dom_null::NTuple{N,Function},
    dims::NTuple{N,Int}
) where {N}
    ntuple(i -> feasible_init_one(dom_nneg[i], dom_null[i], dims[i]), N)
end

function oracle(
    payoffs::NTuple{2,Function},
    dom_nneg::NTuple{2,Function},
    dom_null::NTuple{2,Function},
    actions::NTuple{2,AbstractVector},
    weights::NTuple{2}
)
    slice = unilateral_payoffs_continuous(payoffs, actions, weights)
    improved = ntuple(i -> best_response(slice[i], dom_nneg[i], dom_null[i], last(actions[i])), 2)

    maxes = ntuple(i -> improved[i][1], 2)
    acts = ntuple(i -> improved[i][2], 2)

    maxes, acts
end