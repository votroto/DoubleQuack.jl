function max_incentive(_, _, values::NTuple{N,F}, best::NTuple{N,F}) where {N,F}
    incentive_max = typemin(F)
    for i in eachindex(values)
        incentive_i = best[i] - values[i]
        if incentive_i > incentive_max
            incentive_max = incentive_i
        end
    end
    incentive_max
end

function unilateral_payoffs_continuous(
    payoffs::NTuple{N,Function},
    actions::NTuple{N, AbstractVector},
    weights::NTuple{N}
) where {N}
    function deviation(i, x)
        weval(w, a) = prod(w) * payoffs[i](a...)
        part_weights = ntuple(j -> (j == i) ? [1] : weights[j], N)
        part_actions = ntuple(j -> (j == i) ? [x] : actions[j], N)
        prod_actions = Iterators.product(part_actions...)
        prod_weights = Iterators.product(part_weights...)
        mapreduce(weval, +, prod_weights, prod_actions)
    end

    ntuple(i -> x -> deviation(i, x), N)
end

function epspush(xs::Vector{NTuple{N, F}}, y; eps=1e-6) where {N,F}
    ys = NTuple{N, F}[]
    for x in xs
        cont = false
        for i in 1:N
            cont |= !isapprox(x[i], y[i]; rtol=eps)
        end
        if cont
            push!(ys, x)
        end
    end
    push!(ys, y)

    ys
end