# DoubleQuack.jl
Two-player zero-sum continous game solver.

## Install
Install the package directly from Github. Open `Pkg` mode with `]`, then
```jl
add https://github.com/votroto/DoubleQuack.jl.git
```

### Gurobi
This package uses Gurobi. You need a valid license to use it.
Supress debugging output by creating `gurobi.env` in your current folder, and paste into it the settings:
```
OutputFlag 0
LogToConsole 0
```

## Model 1: Nie 2021, Example 6.1.(i)
Consider the following two-player zero-sum continuous game with $3\times 3$ variables, where Player 1 has the loss function:

$l_1(\mathbf{x}, \mathbf{y}) = x_1x_2 + x_2x_3 + x_3y_1 + x_1y_3 + y_1y_2 + y_2y_3$

and where the strategy spaces are symmetrically defined by

$v_i \ge 0 \quad \forall i \in \{1,2,3\}$,

$\sum_{i=1}^3 v_i = 1$.

We model it in DoubleQuack as
```julia
l(x, y) = x[1]x[2] + x[2]x[3] + x[3]y[1] + x[1]y[3] + y[1]y[2] + y[2]y[3]

g = @game x{3} y{3} begin
    -l(x, y)
    l(x, y)
end
@strategy_set g x begin
    x .>= 0
    sum(x) == 1
end
@strategy_set g y begin
    y .>= 0
    sum(y) == 1
end
```

The game has a known saddle point at $x^\star = (0, 1, 0)$ and $y^\star = (0.25, 0.5, 0.25)$.

## Model 2: Stein 2008, Example 2.3
Consider the following two-player general-sum continuous game with $1\times 1$ variables, where Player 1 has the utility function:

$u_1(\mathbf{x}, \mathbf{y}) = 0.2x_1y_1 - \cos(y_1)$

The strategy spaces are: $-1 \leq x_1 \leq 1$ and $-1 \leq y_1 \leq 1$.

We model it in DoubleQuack as
```julia
g = @game x{1} y{1} begin
    2 * x[1] * y[1] + 3y[1]^3 - 2x[1]^3 - x[1] - 3x[1]^2 * y[1]^2
    2x[1]^2 * y[1]^2 - 4y[1]^3 - x[1]^2 + 4y[1] + x[1]^2 * y[1]
end
@strategy_set g x begin
    x[1] >= -1
    x[1] <= 1
end
@strategy_set g y begin
    y[1] >= -1
    y[1] <= 1
end
```

## Experiment

Find the $\epsilon$-NE of either game with $\epsilon=0.001$ using:
```julia
result = solve(g, eps=1e-3, max_iters=20)
DoubleQuack.clean_print_ne(result)
```
the result is a mixed strategy $\epsilon$-NE