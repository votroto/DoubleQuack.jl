
function ex_parrilo06_2_1()
    # Example 2.1
    # mixed NE
    # (1.0,), 50.0 %; (-1.0,), 50.0 %;
    # (0.0,), 100.0 %;

    g = @game (x{1}, y{1}) begin
        (x[1] - y[1])^2
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end

function ex_parrilo06_3_1()
    # Example 3.1
    # NE
    # (4^(-2/4),), 100.0 %;
    # (4^(-1/4),), 100.0 %;

    g = @game (x{1}, y{1}) begin
        2 * x[1] * y[1]^2 - x[1]^2 - y[1]
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end

function ex_parrilo06_3_2()
    # Example 3.2
    # mixed NE
    # (0.2,), 100.0 %;
    # (1.0,), 78 %; (-1.0,), 22 %;

    u(x, y) = 5 * x * y - 2 * x^2 - 2 * x * y^2 - y

    g = @game (x{1}, y{1}) begin
        u(x[1], y[1])
    end
    @strategy_set g (x, y) in [-1,1]

    g
end

function ex_razaviyayn20_5_1()
    u(x, y) = 0.2 * x * y - cos(y)

    g = @game (x{1}, y{1}) begin
        u(x[1], y[1])
    end
    @strategy_set g x in [-1, 1]
    @strategy_set g y in [-2π, 2π]

    g
end

function ex_stein08_2_3()
    # mixed NE
    # (-1.0,), 55.32 %; (0.1149,), 44.68 %;
    # (0.7166,), 100 %;

    g = @game (x{1}, y{1}) begin
        2 * x[1] * y[1] + 3y[1]^3 - 2x[1]^3 - x[1] - 3x[1]^2 * y[1]^2
        2x[1]^2 * y[1]^2 - 4y[1]^3 - x[1]^2 + 4y[1] + x[1]^2 * y[1]
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end


function ex_zheng23_convex_nonconcave()
    g = @game (x{1}, y{1}) begin
        -(2 * x[1]^2 - y[1]^2 + 4 * x[1] * y[1] + 4 / 3 * y[1]^3 - 1 / 4 * y[1]^4)
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end

function ex_zheng23_kl_nonconcave()
    g = @game (x{1}, y{1}) begin
        -(x[1]^2 + 3 * sin(x[1])^2 * sin(y[1])^2 - 4 * y[1]^2 - 10 * sin(y[1])^2)
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end

function ex_zheng23_bilinearly_coupled_minimax()
    A = 10
    f(z) = (z + 1) * (z - 1) * (z + 3) * (z - 3)

    g = @game (x{1}, y{1}) begin
        -(f(x[1]) + A * x[1] * y[1] - f(y[1]))
    end
    @strategy_set g (x, y) in [-4, 4]

    g
end

function ex_zheng23_forsaken()
    phi(z) = 1/4*z^2 - 1/2 * z^4 + 1/6*z^6

    g = @game (x{1}, y{1}) begin
        -(x[1]*(y[1]-0.45) + phi(x[1]) - phi(y[1]))
    end
    @strategy_set g (x, y) in [-1.5, 1.5]

    g
end

function ex_chasnov20_5_2()
    # two pure equilibria at (-1.063, 1.014) and (1.408, -0.325).

    phi = (0, π / 8)
    alp = (1, 1.5)

    g = @game (x{1}, y{1}) begin
        alp[1] * cos(x[1] − phi[1]) - cos(x[1] - y[1])
        alp[2] * cos(y[1] − phi[2]) - cos(y[1] - x[1])
    end
    @strategy_set g (x, y) in [-π, π]

    g
end

function ex_chasnov20_b_1()
    # pure equilibrium at x=0.5, y=0.5

    e = exp(1)
    soft(x) = [e^(10*x)/(e^(10*x)+e^(10*(1-x))), e^(10*(1-x))/(e^(10*x)+e^(10*(1-x)))]

    A = [1 -1; -1 1]

    g = @game (x{1}, y{1}) begin
        -soft(y[1])' * A * soft(x[1])
    end
    @strategy_set g (x, y) in [0, 1]

    g
end

function ex_stein07_4_3_1()
    # correlated NE
    # x = 1, y = 1

    g = @game (x{1}, y{1}) begin
        0.596 * x[1]^2 + 2.072 * x[1] * y[1] - 0.394 * y[1]^2 + 1.360 * x[1] - 1.200 * y[1] + 0.554
        -0.108 * x[1]^2 + 1.918 * x[1] * y[1] - 1.044 * y[1]^2 - 1.232 * x[1] + 0.842 * y[1] - 1.886
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end

function ex_ratliff13_location()
    # NE
    # x=1; y=-1.1
    # x=-1; y=1.1
    # x=0; y=pi ???

    alp = (1, 1.05)

    g = @game (x{1}, y{1}) begin
        cos(x[1]) - alp[1]*cos(x[1] - y[1])
        cos(y[1]) - alp[2]*cos(y[1] - x[1])
    end
    @strategy_set g (x, y) in [-π, π]

    g
end


function ex_mertikopoulos18_fig1()
    v1(x,y) = ((x-0.5)*(y-0.5)+1/3*exp(-(x-1/4)^2-(y-3/4)^2))

    g = @game (x{1}, y{1}) begin
        v1(x[1], y[1])
    end
    @strategy_set g (x, y) in [0, 1]

    g
end

function ex_mertikopoulos18_2_2()
    # The only saddle-point of f is x∗ = (0, 0): it

    v1(x,y) = -(x^4*y^2+x^2+1)*(x^2*y^4-y^2+1)

    g = @game (x{1}, y{1}) begin
        v1(x[1], y[1])
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end


function ex_karlin59_vol2_sec71_ex1()
    lam = 0.5
    v1(x, y) = 1 / (1 + lam * (x - y)^2)

    g = @game (x{1}, y{1}) begin
        v1(x[1], y[1])
    end
    @strategy_set g (x, y) in [0, 1]

    g
end

function ex_karlin59_vol2_sec71_ex2()
    # NE
    # cantor distribution

    v1(x, y) = (y - 0.5) * ((1 + (x - 0.5) * (y - 0.5)^2) / (1 + (x - 0.5)^2 * (y - 0.5)^4) - 1 / (1 + (x / 3 - 0.5) * (y - 0.5)^4))

    g = @game (x{1}, y{1}) begin
        v1(x[1], y[1])
    end
    @strategy_set g (x, y) in [0, 1]

    g
end

function ex_karlin59_vol2_sec76_pr1()
    v1(x, y) = 2*(x+y)/((2*x+1)*(2*y+1))

    g = @game (x{1}, y{1}) begin
        v1(x[1], y[1])
    end
    @strategy_set g (x, y) in [0, 1]

    g
end

function ex_karlin59_vol2_sec76_pr2()
    v1(x, y) = ((1+x)*(1+y))/(1+x*y)^2

    g = @game (x{1}, y{1}) begin
        v1(x[1], y[1])
    end
    @strategy_set g (x, y) in [0, 1]

    g
end

function ex_dresher61_pg110()
    # mixed NE
    # (0.0,), 50.0 %; (1.0,), 50.0 %;
    # (0.5,), 100.0 %;
    # v=1/4

    g = @game (x{1}, y{1}) begin
        (x[1] - y[1])^2
    end
    @strategy_set g (x, y) in [0, 1]

    g
end

function ex_dresher61_pg111()
    # v = 1/6

    g = @game (x{1}, y{1}) begin
        sqrt((y[1]-x[1])^2)*(y[1]-x[1])^2
    end
    @strategy_set g (x, y) in [0, 1]

    g
end


function ex_nie21_6_1_i()
    # Example 6.1 (i)
    # Saddle point
    # x∗ = (0.0000, 1.0000, 0.0000), y∗ = (0.2500, 0.5000, 0.2500).

    l(x, y) = x[1]x[2] + x[2]x[3] + x[3]y[1] + x[1]y[3] + y[1]y[2] + y[2]y[3]

    g = @game (x{3}, y{3}) begin
        -l(x, y)
    end
    @strategy_set g (x, y) as v in begin
        v .>= 0
        sum(v) == 1
    end

    g
end

function ex_nie21_6_1_ii()
    # Example 6.1 (ii)
    # Saddle point
    # x∗ = (0.0000, 0.0000, 1.0000), y∗ = (0.0000, 0.0000, 1.0000).

    g = @game (x{3}, y{3}) begin
        -(x[1]^3 + x[2]^3 - x[3]^3 - y[1]^3 - y[2]^3 + y[3]^3 + x[3] * y[1] * y[2] * (y[1] + y[2]) + x[2] * y[1] * y[3] * (y[1] + y[3]) + x[1] * y[2] * y[3] * (y[2] + y[3]))
    end
    @strategy_set g (x, y) as v in begin
        v .>= 0
        sum(v) == 1
    end

    g
end

function ex_nie21_6_1_iii()
    # Example 6.1 (iii)
    # Saddle point
    # x∗ = (0.2500, 0.2500, 0.2500, 0.2500), y∗ = ei

    g = @game (x{4}, y{4}) begin
        -(sum(x[i]^2 * y[i]^2 for i in 1:4, j in 1:4) - sum(x[i] * x[j] + y[i] * y[j] for i in 1:4, j in 1:4 if i != j))
    end
    @strategy_set g (x, y) as v in begin
        v .>= 0
        sum(v) == 1
    end

    g
end

function ex_nie21_6_1_iv()
    # Example 6.1 (iv)
    # no saddle points

    g = @game (x{3}, y{3}) begin
        -(x[1] * x[2] * y[1] * y[2] + x[2] * x[3] * y[2] * y[3] + x[3] * x[1] * y[3] * y[1] - x[1]^2 * y[3]^2 - x[2]^2 * y[1]^2 - x[3]^2 * y[2]^2)
    end
    @strategy_set g (x, y) as v in begin
        v .>= 0
        sum(v) == 1
    end

    g
end

function ex_nie21_6_2_i()
    # Example 6.2 (i)
    # saddle point
    # x∗ = (0.3249, 0.3249), y∗ = (1.0000, 0.0000)
    # - seemingly also all x[1]=x[2] < 0.8?

    g = @game (x{2}, y{2}) begin
        -((x[1] + x[2] + y[1] + y[2] + 1)^2 - 4 * (x[1] * x[2] + x[2] * y[1] + y[1] * y[2] + y[2] + x[1]))
    end
    @strategy_set g (x, y) in [0, 1]

    g
end


function ex_nie21_6_2_ii()
    # Example 6.2 (ii)
    # no saddle point

    g = @game (x{3}, y{3}) begin
        -(sum(x[i] + y[i] for i in 1:3) + sum(x[i]^2 * y[j]^2 - y[i]^2 * x[j]^2 for i in 1:3, j in 1:3 if i < j))
    end
    @strategy_set g (x, y) in [0, 1]

    g
end


function ex_nie21_6_3_i()
    # Example 6.3 (i)
    # saddle points:
    # x∗ = (−1.0000, −1.0000, 1.0000), y∗ = (1.0000, 1.0000, 1.0000),
    # x∗ = (−1.0000, 1.0000, −1.0000), y∗ = (1.0000, 1.0000, 1.0000),
    # x∗ = (1.0000, −1.0000, −1.0000), y∗ = (1.0000, 1.0000, 1.0000).

    g = @game (x{3}, y{3}) begin
        -(sum(x[i] + y[i] for i in 1:3) - prod(x[i] - y[i] for i in 1:3))
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end


function ex_nie21_6_3_ii()
    # Example 6.3 (ii)
    # saddle points:
    # x∗ = (−1.0000, 1.0000, −1.0000), y∗ = (−1.0000, 1.0000, −1.0000)

    g = @game (x{3}, y{3}) begin
        -(sum(y[i]^2 for i in 1:3) - sum(x[i]^2 for i in 1:3) + sum(x[i] * y[j] - x[j] * y[i] for i in 1:3, j in 1:3 if i < j))
    end
    @strategy_set g (x, y) in [-1, 1]

    g
end


function ex_nie21_6_4_i()
    # Example 6.4 (i)
    # saddle points:
    # (−ei , ej)

    g = @game (x{3}, y{3}) begin
        -(x[1]^3 + x[2]^3 + x[3]^3 + y[1]^3 + y[2]^3 + y[3]^3 + 2 * (x[1] * x[2] * y[1] * y[2] + x[1] * x[3] * y[1] * y[3] + x[2] * x[3] * y[2] * y[3]))
    end
    @strategy_set g (x, y) as v in begin
        v[1]^2 + v[2]^2 + v[3]^2 == 1
    end

    g
end


function ex_nie21_6_4_ii()
    # Example 6.4 (ii)
    # no saddle points

    g = @game (x{3}, y{3}) begin
        -(x[1]^2 * y[1]^2 + x[2]^2 * y[2]^2 + x[3]^2 * y[3]^2 + x[1]^2 * y[2] * y[3] + x[2]^2 * y[1] * y[3] + x[3]^2 * y[1] * y[2] + y[1]^2 * x[2] * x[3] + y[2]^2 * x[1] * x[3] + y[3]^2 * x[1] * x[2])
    end
    @strategy_set g (x, y) as v in begin
        v[1]^2 + v[2]^2 + v[3]^2 == 1
    end

    g
end

function ex_nie21_6_5()
    # Example 6.5
    # saddle points
    # x∗ = (0.7264, 0.4576, 0.3492), y∗ = (0.6883, 0.5463, 0.4772).

    g = @game (x{3}, y{3}) begin
        -(x[1]^2 * y[1] + 2 * x[2]^2 * y[2] + 3 * x[3]^2 * y[3] − x[1] − x[2] − x[3])
    end
    @strategy_set g (x, y) as v in begin
        v[1]^2 + v[2]^2 + v[3]^2  <= 1
    end

    g
end

function ex_nie21_6_6()
    # Example 6.6
    # no saddle points

    g = @game (x{3}, y{3}) begin
        -(x[1]^2 * y[2] * y[3] + y[1]^2 * x[2] * x[3] + x[2]^2 * y[1] * y[3] + y[2]^2 * x[1] * x[3] + x[3]^2 * y[1] * y[2] + y[3]^2 * x[1] * x[2])
    end
    @strategy_set g (x, y) as v in begin
        v[1]^2 + v[2]^2 + v[3]^2  <= 1
    end

    g
end

function ex_nie21_6_10()
    # Example 6.10
    # two Nash equilibria
    # x∗ = (0, 1, 0, 0, 0), y∗ = (1, 0, 0, 0, 0),
    # x∗ = (0, 1, 0, 0, 0), y∗ = (0, 1, 0, 0, 0).

    A1 = [-4 4 0 3 -4; 3 4 3 -4 -5; -3 0 -2 0 4; -4 -4 -1 3 -5; 4 1 -3 0 -5]
    A2 = [-4 4 1 0 1; -2 -4 2 -3 1; -3 1 1 4 4; 3 -4 0 1 -2; -1 -3 -1 3 -2]
    B = [-2 -4 -2 -5 3; 0 0 2 4 2; 0 -4 -1 -5 3; 1 -3 -4 0 -3; 3 -1 -5 4 -4]

    g = @game (x{5}, y{5}) begin
        sum(x[i] * A1[i, j] * x[j] for i in 1:5, j in 1:5) + sum(y[i] * A2[i, j] * y[j] for i in 1:5, j in 1:5) + sum(x[i] * B[i, j] * y[j] for i in 1:5, j in 1:5)
    end
    @strategy_set g (x, y) as v in begin
        v .>= 0
        sum(v) == 1
    end

    g
end

examples = [ex_parrilo06_2_1, ex_parrilo06_3_1, ex_parrilo06_3_2, ex_razaviyayn20_5_1, ex_stein08_2_3, ex_zheng23_convex_nonconcave, ex_zheng23_kl_nonconcave, ex_zheng23_bilinearly_coupled_minimax, ex_zheng23_forsaken, ex_chasnov20_5_2, ex_chasnov20_b_1, ex_stein07_4_3_1, ex_ratliff13_location, ex_mertikopoulos18_fig1, ex_mertikopoulos18_2_2, ex_karlin59_vol2_sec71_ex1, ex_karlin59_vol2_sec71_ex2, ex_karlin59_vol2_sec76_pr1, ex_karlin59_vol2_sec76_pr2, ex_dresher61_pg110, ex_dresher61_pg111, ex_nie21_6_1_i, ex_nie21_6_1_ii, ex_nie21_6_1_iii, ex_nie21_6_1_iv, ex_nie21_6_2_i, ex_nie21_6_2_ii, ex_nie21_6_3_i, ex_nie21_6_3_ii, ex_nie21_6_4_i, ex_nie21_6_4_ii, ex_nie21_6_5, ex_nie21_6_6, ex_nie21_6_10]

examples = [ex_nie21_6_10]
for e in examples
    println(nameof(e))
    ne = solve(e(), eps=1e-3, max_iters=30)
    DoubleQuack.clean_print_ne(ne)
end
