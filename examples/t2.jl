using DoubleQuack
using Symbolics
using Base.Iterators: take

include("utils.jl")


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
print_exploitability(es)
