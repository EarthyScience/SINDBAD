module Sinbad

using Reexport: @reexport
@reexport begin
    using Parameters, TypedTables
end

export runEcosystem, evolveEcosystem
export SnowFrac, rainSnow, snowMelt, run, getforcing

include("Ecosystem.jl")
include("utils.jl")
include("./models/rainSnow.jl")
include("./models/snowMelt.jl")

end
