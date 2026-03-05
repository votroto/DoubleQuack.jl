module DoubleQuack

export solve
export Game, @game, @strategy_set, game_set_nneg!, game_set_null!

include("utils.jl")
include("game.jl")
include("iterable.jl")
include("oracle.jl")
include("equilibrium.jl")

end