# DoubleQuack.jl
Two-player zero-sum continous game solver.

## Install
Install the package directly from Github. Open `Pkg` mode with `]`, then
```jl
add https://github.com/votroto/DoubleQuack.jl.git
```

## Model 1: Nie 2021, Example 6.1.(i)
Consider the following two-player zero-sum continuous game with $3\times 3$ variables, where Player 1 has the following loss function:
$$l_1(\mathbf{x}, \mathbf{y}) = x_1x_2 + x_2x_3 + x_3y_1 + x_1y_3 + y_1y_2 + y_2y_3$$
and where the strategy spaces are symmetrically defined by
$$
\begin{aligned}
v_i &\ge 0 \quad \forall i \in \{1,2,3\}\\
\sum_{i=1}^3 v_i &= 1
\end{aligned}
$$

We model it in DoubleQuack as
```julia
function ex_nie21_6_1_i()
    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    u1(x, y) = -(x[1] * x[2] + x[2] * x[3] + x[3] * y[1] + x[1] * y[3] + y[1] * y[2] + y[2] * y[3])

    u1, (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end
```

The game has a known saddle point at `x∗ = (0.0000, 1.0000, 0.0000)` and `y∗ = (0.2500, 0.5000, 0.2500)`.

## Model 2: Razaviyayn 2020, Example 5.1
Consider the following two-player zero-sum continuous game with $1\times 1$ variables, where Player 1 has the following utility function:
$$u_1(\mathbf{x}, \mathbf{y}) = 0.2x_1y_1 - cos(y_1)$$
The strategy space of Player 1 is
$$
-1 \leq x_1 \leq 1
$$
and the strategy space of Player 2 is
$$
-2\pi \leq y_1 \leq 2\pi
$$

We model it in DoubleQuack as
```julia
function ex_razaviyayn20_5_1()
    dom_nneg1(x) = (1 + x[1], 1 - x[1])
    dom_nneg2(x) = (2 * pi + x[1], 2 * pi - x[1])
    dom_null(x) = 0

    u1(x, y) = 0.2 * x[1] * y[1] - cos(y[1])

    u1, (dom_nneg1, dom_nneg2), (dom_null, dom_null), (1, 1)
end
```

## Experiment

Find the $\epsilon$-NE of either game with $\epsilon=0.001$ using:
```julia
util, nneg, null, dims = ex_razaviyayn20_5_1()
quack = DoubleQuack.quack_oracle(util, nneg, null, dims)
@time cnt, (actions, mixed, vals, best) = DoubleQuack.until_eps(quack, 1e-3)

DoubleQuack.clean_print(actions, mixed)
```

the result is a mixed strategy $\epsilon$-NE

```
0.014117 seconds (27.28 k allocations: 665.922 KiB)

Player 1 - Centered at (0.0,):
      50.0% (-1.0,)
      50.0% (1.0,)

Player 2 - Centered at (-0.0,):
      50.0% (6.283,)
      50.0% (-6.283,)

```