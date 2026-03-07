function split_array(arr, by)
    result = []
    sub = []

    for item in arr
        if item == by
            if !isempty(sub)
                push!(result, sub)
                sub = []
            end
        else
            push!(sub, item)
        end
    end
    push!(result, sub)

    return result
end


function __parse_strategy_set(bind, set)
    constr_expr(dotted, e1, e2) = dotted ? :(($e1 .- $e2)...) : :($e1 - $e2)

    @assert set isa Expr

    nneg_exprs = Any[1]
    null_exprs = Any[0]

    if set.head == :block
        for ex in set.args
            ex isa LineNumberNode && continue

            if !(ex isa Expr && ex.head == :call)
                error("Expected comparison expression, got $ex")
            end

            op, lhs, rhs = ex.args
            dotted = op isa Symbol && startswith(String(op), ".")
            baseop = dotted ? Symbol(String(op)[2:end]) : op

            if baseop == :(>=)
                push!(nneg_exprs, constr_expr(dotted, lhs, rhs))
            elseif baseop == :(<=)
                push!(nneg_exprs, constr_expr(dotted, rhs, lhs))
            elseif baseop == :(==)
                push!(null_exprs, constr_expr(dotted, lhs, rhs))
            else
                error("Unsupported constraint: $ex.")
            end
        end
    elseif set.head == :vect && length(set.args) == 2
        lo, hi = set.args
        push!(nneg_exprs, :($bind .- $(esc(lo))))
        push!(nneg_exprs, :($(esc(hi)) .- $bind))
    else
        error("Did not understand strategy set definition.")
    end

    nneg_lambda = :($bind -> tuple($(nneg_exprs...)))
    null_lambda = :($bind -> tuple($(null_exprs...)))

    nneg_lambda, null_lambda
end


function parse_direct_constrs(syms, constr_arg)
    nneg_dict = Dict{Symbol, Any}()
    null_dict = Dict{Symbol, Any}()
    for c in split_array(constr_arg, :with)
        # kingdom for a pattern match!
        vars, bnd, set =
            if length(c) == 1 && c[1].head == :call && c[1].args[1] == :in
                [c[1].args[2]], c[1].args[2], c[1].args[3]
            elseif length(c) == 3 && c[2] == :as && c[3].head == :call && c[3].args[1] == :in && c[1].head == :tuple
                c[1].args, c[3].args[2], c[3].args[3]
            else
                error("Did not understand constraint $c")
            end
        nn, nu = __parse_strategy_set(bnd, set)
        for v in vars

            nneg_dict[v] = nn
            null_dict[v] = nu
        end
    end

    nneg_tuple = ntuple(i -> get(nneg_dict, syms[i], 1), length(syms))
    null_tuple = ntuple(i -> get(null_dict, syms[i], 0), length(syms))

    nneg_tuple, null_tuple
end

macro game(var_arg, util_arg, constr_arg...)
    @assert var_arg.head == :tuple

    params = [var.args[1] for var in var_arg.args]
    dims = [var.args[2] for var in var_arg.args]
    syms = [QuoteNode(var.args[1]) for var in var_arg.args]
    utils = [esc(:(($(params...),) -> $e)) for e in util_arg.args if e isa Expr]
    nn, nu = parse_direct_constrs(params, constr_arg)

    quote
        @show $nn
        @show $nu
    end
end

lll = @game (x{2}, y{3}, z{1}) begin
    x[1]*x[2] - y[1]*y[3] + z[1]
    y[1]*y[2] - cos(x[2]) + z[1]
    y[1]*y[3] - z[1]^2
end with (x, y) as v in begin
    sum(v) == 1
    v .>= 0
end with z in [-2π, 2π]


