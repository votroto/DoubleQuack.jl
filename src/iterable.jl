import Base: iterate, IteratorSize, IsInfinite
using LinearAlgebra
using Base.Iterators: dropwhile, flatten, take, drop

dropwhile_enumerate(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))

until_eps(xs, gap) = first(dropwhile_enumerate(x -> max_incentive(x...) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))

struct QuackIterable{N,I}
    payoffs::NTuple{N,Function}
    dom_nneg::NTuple{N,Function}
    dom_null::NTuple{N,Function}
    dims::NTuple{N,Int}
    start::I
end

IteratorSize(::Type{QuackIterable}) = IsInfinite()

function quack_oracle(
    payoffs::NTuple{N,Function},
    dom_nneg::NTuple{N,Function},
    dom_null::NTuple{N,Function},
    dims::NTuple{N,Int};
    start=feasible_init(dom_nneg, dom_null, dims)
) where {N}
    QuackIterable(payoffs, dom_nneg, dom_null, dims, start)
end

function iterate(mo::QuackIterable, actions=mo.start)
    payoffs, dom_nneg, dom_null = mo.payoffs, mo.dom_nneg, mo.dom_null

    values, mixed = equilibrium(payoffs, actions)
    best, responses = oracle(payoffs, dom_nneg, dom_null, actions, mixed)
    extended = epspush.(actions, responses)

    (actions, mixed, values, best), extended
end