module DoubleQuack

export quack_oracle, interior_init, oracle
export until_eps, fixed_iters

include("utils.jl")
include("symbolics_utils.jl")
include("iterable.jl")
include("oracle.jl")
include("zerosum_nash.jl")
include("equilibrium.jl")

end