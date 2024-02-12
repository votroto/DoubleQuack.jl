function run_experiment_solve(p, ds, vs; iterations)
    quack = DoubleQuack.quack_oracle(p, ds, vs)
    pure, prob, _ = DoubleQuack.fixed_iters(quack, iterations)

    pure, prob
end

@variables x[1:6]

payoff = sum(x[i] + x[3+i] for i in 1:3) - prod((x[i] - x[3+i]) for i in 1:3)

dom1 = (x[1]^2 ≲ 1, x[2]^2 ≲ 1, x[3]^2 ≲ 1)
dom2 = (x[4]^2 ≲ 1, x[5]^2 ≲ 1, x[6]^2 ≲ 1,)
domains = (dom1, dom2)

variables = ((x[1], x[2], x[3]), (x[4], x[5], x[6]))

pure, prob = run_experiment_solve(-payoff, domains, variables; iterations=15)

println("Example: Find equilibrium")
clean_print(pure, prob)