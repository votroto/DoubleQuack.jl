# DoubleQuack.jl
IPopt double-oracle.

## Install
Install the package directly from Github.
```jl
]add https://github.com/votroto/DoubleQuack.jl.git
```

## Example 1: Find a mixed strategy
```jl
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
```
Results in
```
Player 1 - Centered at (-0.333, -0.333, -0.333):
      33.3% (1.0, -1.0, -1.0)
      33.3% (-1.0, 1.0, -1.0)
      33.3% (-1.0, -1.0, 1.0)

Player 2 - Centered at (1.0, 1.0, 1.0):
     100.0% (1.0, 1.0, 1.0)
```

## Example 2: Exploitability sequence
```
function run_experiment_exploit(p, ds, vs; iterations)
    quack = DoubleQuack.quack_oracle(p, ds, vs)

    exploit = Array{Float64}(undef, iterations)
    iter = 1
    for (_, _, _, best) in take(quack, iterations)
        exploit[iter] = sum(best)
        iter += 1
    end

    exploit
end

@variables x y

payoff = 5*x*y-2x^2-2*x*y^2-y
doms = ((x^2 ≲ 1,), (y^2 ≲ 1,))
vars = ((x,), (y,))

es = run_experiment_exploit(payoff, doms, vars; iterations=10)
```
Results in
```
1.000
1.125
1.615
0.070
0.018
0.004
0.001
0.000
0.000
0.000
0.000
0.000
0.000
0.000
0.000
```