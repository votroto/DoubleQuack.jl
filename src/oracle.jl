using NLPModelsIpopt: ipopt

import SymNLPModels as NLP
import Symbolics as Sym


function interior_init(
    domains;
    variables=domains_variables(domains)
)
    player_vals(sol, vs) = map(v -> NLP.value(sol, v), vs)
    all_inits(sol) = map(vs -> [player_vals(sol, vs)], variables)

    domcat = collect(tuplecat(domains...))
    varcat = tuplecat(variables...)
    interior = Sym.Num(sum(_inequality_to_expr.(domcat)))

    model = NLP.SymNLPModel(interior, domcat; variables=varcat)
    stats = ipopt(model; print_level=0)

    solution = NLP.parse_solution(model, stats.solution)

    all_inits(solution)
end

function oracle(payoff, domain, variables)
    num_vars = length(variables)

    model = NLP.SymNLPModel(-payoff, collect(domain); variables=collect(variables))
    stats = ipopt(model; print_level=0)

    solution = NLP.parse_solution(model, stats.solution)
    maximizers = ntuple(i -> NLP.value(solution, variables[i]), num_vars)

    -stats.objective, maximizers
end

function oracle(payoff, domains, actions, weights, variables)
    players = eachindex(variables)

    unilateral = best_response_functions(payoff, actions, weights, variables)
    improved = [
        oracle(unilateral[i], domains[i], variables[i])
        for i in players
    ]
    vals, args = unzip(improved)
    Tuple(vals), Tuple(args)
end