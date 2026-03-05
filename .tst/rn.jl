using Revise
include("../src/DoubleQuack.jl")
using Main.DoubleQuack

razaviyayn20_5_1 = @game x{1} y{1} begin
    0.2 * x[1] * y[1] - cos(y[1])
    -(0.2 * x[1] * y[1] - cos(y[1]))
end

@strategy_set razaviyayn20_5_1 x begin
    x[1] >= -1
    x[1] <= 1
end

@strategy_set razaviyayn20_5_1 y begin
    y[1] >= -2π
    y[1] <= 2π
end

equilibrium = solve(razaviyayn20_5_1, eps=1e-3, max_iters=20)
DoubleQuack.clean_print(equilibrium[1],equilibrium[2])
