function ex_parrilo06_2_1()
    # Example 2.1
    # mixed NE
    # (1.0,), 50.0 %; (-1.0,), 50.0 %;
    # (0.0,), 100.0 %;

    g = @game x{1} y{1} begin
        (x[1] - y[1])^2
    end
    @strategy_set g x y as v in begin
        v .<= 1
        v .>= -1
    end

    g
end

function ex_parrilo06_3_1()
    # Example 3.1
    # NE
    # (4^(-2/4),), 100.0 %;
    # (4^(-1/4),), 100.0 %;

    g = @game x{1} y{1} begin
        2 * x[1] * y[1]^2 - x[1]^2 - y[1]
    end
    @strategy_set g x y as v in begin
        v .<= 1
        v .>= -1
    end

    g
end

function ex_parrilo06_3_2()
    # Example 3.2
    # mixed NE
    # (0.2,), 100.0 %;
    # (1.0,), 78 %; (-1.0,), 22 %;

    u(x, y) = 5 * x * y - 2 * x^2 - 2 * x * y^2 - y

    g = @game x{1} y{1} begin
        u(x[1], y[1])
    end
    @strategy_set g x y as v in begin
        v .<= 1
        v .>= -1
    end

    g
end

function ex_nie21_6_1_i()
    l(x, y) = x[1]x[2] + x[2]x[3] + x[3]y[1] + x[1]y[3] + y[1]y[2] + y[2]y[3]

    g = @game x{3} y{3} begin
        -l(x, y)
    end
    @strategy_set g x y as v in begin
        v .>= 0
        sum(v) == 1
    end

    g
end

function ex_razaviyayn20_5_1()
    u(x, y) = 0.2 * x * y - cos(y)

    g = @game x{1} y{1} begin
        u(x[1], y[1])
    end
    @strategy_set g x begin
        x[1] >= -1
        x[1] <= 1
    end
    @strategy_set g y begin
        y[1] >= -2π
        y[1] <= 2π
    end

    g
end

function ex_stein08_2_3()
    # mixed NE
    # (-1.0,), 55.32 %; (0.1149,), 44.68 %;
    # (0.7166,), 100 %;

    g = @game x{1} y{1} begin
        2 * x[1] * y[1] + 3y[1]^3 - 2x[1]^3 - x[1] - 3x[1]^2 * y[1]^2
        2x[1]^2 * y[1]^2 - 4y[1]^3 - x[1]^2 + 4y[1] + x[1]^2 * y[1]
    end
    @strategy_set g x y as v in begin
        v[1] >= -1
        v[1] <= 1
    end

    g
end

ne_parrilo06_2_1 = solve(ex_parrilo06_2_1(), eps=1e-3, max_iters=20)
ne_parrilo06_3_1 = solve(ex_parrilo06_3_1(), eps=1e-3, max_iters=20)
ne_parrilo06_3_2 = solve(ex_parrilo06_3_2(), eps=1e-3, max_iters=20)
ne_nie21_6_1_i = solve(ex_nie21_6_1_i(), eps=1e-3, max_iters=20)
ne_razaviyayn20_5_1 = solve(ex_razaviyayn20_5_1(), eps=1e-3, max_iters=20)

DoubleQuack.clean_print_ne(ne_parrilo06_2_1)
DoubleQuack.clean_print_ne(ne_parrilo06_3_1)
DoubleQuack.clean_print_ne(ne_parrilo06_3_2)
DoubleQuack.clean_print_ne(ne_nie21_6_1_i)
DoubleQuack.clean_print_ne(ne_razaviyayn20_5_1)
