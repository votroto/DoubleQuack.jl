using Printf


function clean_print_strat(pures::Vector{<:NTuple{N}}, probs) where N
    function centeri(j)
        total = sum(probs[i] * pures[i][j] for i in eachindex(probs))
        round(total; digits=3)
    end

    println("Centered at ", ntuple(centeri, N), ":")

    perm = sortperm(probs; rev=true)

    for i in perm
        if probs[i] < 5e-4
            break
        end

        @printf "%10.1f%% %s\n" probs[i]*100 round.(pures[i], digits=3)
    end
end

function clean_print(puress, probss)
    print("Player 1 - ")
    clean_print_strat(puress[1], probss[1])
    println()
    print("Player 2 - ")
    clean_print_strat(puress[2], probss[2])
end

function print_exploitability(exploit)
    println("Exploitability sequence")
    for i in eachindex(exploit)
        @printf "%5.3f\n" exploit[i]
    end
end