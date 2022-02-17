module Sinbad

using Reexport: @reexport
@reexport begin
    using Parameters, TypedTables
end

export runEcosystem, evolveEcosystem
export SnowFrac, rainSnow, snowMelt, run, getforcing
export evapSoil, transpiration, updateState

include("Ecosystem.jl")
include("utils.jl")
include("./models/rainSnow.jl")
include("./models/snowMelt.jl")
include("./models/evapSoil.jl")
include("./models/transpiration.jl")
include("./models/updateState.jl")

end
