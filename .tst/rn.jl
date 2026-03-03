include("../src/DoubleQuack.jl")

function ex_razaviyayn20_5_1()
    dom_nneg1(x) = (1 + x[1], 1 - x[1])
    dom_nneg2(x) = (2 * pi + x[1], 2 * pi - x[1])
    dom_null(x) = 0

    u1(x, y) = 0.2 * x[1] * y[1] - cos(y[1])

    u1, (dom_nneg1, dom_nneg2), (dom_null, dom_null), (1, 1)
end

function ex_nie21_6_1_i()
    # Example 6.1 (i)
    # Saddle point
    # x∗ = (0.0000, 1.0000, 0.0000), y∗ = (0.2500, 0.5000, 0.2500).

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    u1(x, y) = -(x[1] * x[2] + x[2] * x[3] + x[3] * y[1] + x[1] * y[3] + y[1] * y[2] + y[2] * y[3])

    u1, (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

util, nneg, null, dims = ex_razaviyayn20_5_1()
quack = DoubleQuack.quack_oracle(util, nneg, null, dims)
@time cnt, (actions, mixed, vals, best) = DoubleQuack.until_eps(quack, 1e-3)

DoubleQuack.clean_print(actions, mixed)