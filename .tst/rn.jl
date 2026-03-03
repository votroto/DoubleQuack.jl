include("../src/DoubleQuack.jl")

function ex_nie21_6_1_i()
    # Example 6.1 (i)
    # Saddle point
    # x∗ = (0.0000, 1.0000, 0.0000), y∗ = (0.2500, 0.5000, 0.2500).

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    u1(x, y) = -(x[1] * x[2] + x[2] * x[3] + x[3] * y[1] + x[1] * y[3] + y[1] * y[2] + y[2] * y[3])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

utils, nneg, null, dims = ex_nie21_6_1_i()
quack = DoubleQuack.quack_oracle(utils, nneg, null, dims)
@time cnt, (actions, mixed, vals, best) = DoubleQuack.until_eps(quack, 1e-3)
