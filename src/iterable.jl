function solve(
        g::Game{N};
        eps=1e-4,
        max_iters=100,
        delta=1e-6,
        start=feasible_init(g.set_nneg, g.set_null, g.dimensions),
) where {N}
    actions = start
    payoffs, dom_nneg, dom_null = g.utilities, g.set_nneg, g.set_null

    for i in 0:max_iters
        values, mixed = equilibrium(payoffs, actions)
        best, responses = oracle(payoffs, dom_nneg, dom_null, actions, mixed)
        extended = epspush.(actions, responses; delta=1e-6)

        exploitability = max_incentive(values, best)
        if exploitability <= eps
            return (actions, mixed, values, best)
        end
        actions = extended
    end
end