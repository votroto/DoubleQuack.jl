import Base: iterate, IteratorSize, IsInfinite
using LinearAlgebra
using Base.Iterators: dropwhile, flatten, take, drop

dropwhile_enumerate(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))

until_eps(xs, gap) = first(dropwhile_enumerate(x -> max_incentive(x...) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))

struct QuackIterable{I}
    payoff::Function
    dom_nneg::NTuple{2,Function}
    dom_null::NTuple{2,Function}
    dims::NTuple{2,Int}
    start::I
end

IteratorSize(::Type{QuackIterable}) = IsInfinite()

function quack_oracle(
    payoff::Function,
    dom_nneg::NTuple{2,Function},
    dom_null::NTuple{2,Function},
    dims::NTuple{2,Int};
    start=feasible_init(dom_nneg, dom_null, dims)
)
    QuackIterable(payoff, dom_nneg, dom_null, dims, start)
end

function iterate(mo::QuackIterable, actions=mo.start)
    payoff, dom_nneg, dom_null = mo.payoff, mo.dom_nneg, mo.dom_null

    values, mixed = equilibrium(payoff, actions)
    best, responses = oracle(payoff, dom_nneg, dom_null, actions, mixed)
    extended = epspush.(actions, responses)

    (actions, mixed, values, best), extended
end