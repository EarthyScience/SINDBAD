module Sinbad
using JSON
using Reexport: @reexport
@reexport begin
    using Parameters, TypedTables
end

export runEcosystem, evolveEcosystem
<<<<<<< HEAD
export SnowFrac, rainSnow, snowMelt, run, getForcing
export evapSoil, transpiration, updateState, getStates
=======
>>>>>>> 726b9fd (merge of main and tools_skoirala; cleanup, unit conversion)
export runGetConfiguration, setupTEM

include("tem/Ecosystem.jl")
include("tools/utils.jl")
include("tools/getConfiguration.jl")
include("tools/setupTEM.jl")

include("tools/getForcing.jl")
export getForcing

include("tem/sindbadCore.jl")
export getAllModels

### testing getting modules from jl files
include("Models/Models.jl")

end
