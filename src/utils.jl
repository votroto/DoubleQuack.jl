import Symbolics as Sym


max_incentive((_, _, values, best)) = norm(collect(best) - collect(values), Inf)

# Thanks, ivirshup! Julia, please implement.
unzip(a) = map(x -> getfield.(a, x), fieldnames(eltype(a)))

tuplecat(as...) = vcat(collect.(as)...)

player_variables(domain) = Tuple(unique(vcat(Sym.get_variables.(domain)...)))

domains_variables(domains) = map(player_variables, domains)

function best_response_function(payoff_partial, pures, weights)
    total = 0.0
    for (pure, weight) in zip(pures, weights)
        total += weight * payoff_partial(pure)
    end
    Sym.simplify(total; expand=true)
end

function best_response_functions(payoff, pures, weights, variables)
    p_partial1(pure) = +payoff(variables[1], pure)
    p_partial2(pure) = -payoff(pure, variables[2])

    p1 = best_response_function(p_partial1, pures[2], weights[2])
    p2 = best_response_function(p_partial2, pures[1], weights[1])

    p1, p2
end

"""Adds a column to a matrix if it does not exist already"""
function uniqpush(xs, y; atol=1e-8)
    if !any(x -> isapprox(collect(y), collect(x); atol), xs)
        [xs; y]
    else
        xs
    end
end