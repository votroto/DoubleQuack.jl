using Symbolics: build_function, get_variables


function _compile_sym(sym, vars=[get_variables(sym)])
    build_function(sym, vars...; expression=false)
end

function _inequality_to_expr(ineq::Sym.Inequality)
    lhs, rhs, op = ineq.lhs, ineq.rhs, ineq.relational_op
    (op == Sym.geq) ? -lhs + rhs : lhs - rhs
end