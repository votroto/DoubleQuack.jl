import Base: iterate, IteratorSize, IsInfinite
using LinearAlgebra
using Base.Iterators: dropwhile, flatten, take, drop


dropwhile_enumerate(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))

until_eps(xs, gap) = first(dropwhile_enumerate(x -> max_incentive(x) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))

struct QuackIterable{P,D,V,I}
    payoff::P
    domains::NTuple{2,D}
    variables::NTuple{2,V}
    start::NTuple{2,I}
end

IteratorSize(::Type{QuackIterable}) = IsInfinite()

function quack_oracle(
    payoff,
    domains::NTuple{2},
    variables::NTuple{2}=domains_variables(domains);
    start::NTuple{2}=interior_init(domains)
)
    callable = _compile_sym(payoff, variables)
    QuackIterable(callable, domains, variables, start)
end

"""
    iterate(mo::QuackIterable, actions)

Runs one iteration of the Double Oracle algorithm.

Returns the 'actions' and 'probabilities' that make up a mixed strategy in the
current subgame in which only 'actions' can be played; the 'values' of players
at the computed equilibrium of the subgame; and the 'best'-response values of
players.

Next state is the 'extended' action space.

The difference between 'values' and 'best' is the incentive of a player to
deviate.
"""
function iterate(mo::QuackIterable, actions=mo.start)
    payoff, domains, variables = mo.payoff, mo.domains, mo.variables

    values, probs = equilibrium(payoff, actions)
    best, responses = oracle(payoff, domains, actions, probs, variables)
    extended = uniqpush.(actions, responses)

    (actions, probs, values, best), extended
end