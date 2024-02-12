using Base.Iterators: product


_subgame(payoff, actions) = map(a -> payoff(a...), product(actions...))

"""
    equilibrium(payoff, actions)

Compute the player equilibrium strategies in a subgame restricted to actions.
"""
function equilibrium(payoff, actions)
    subproblem = _subgame(payoff, actions)
    nash_equilibrium(subproblem)
end