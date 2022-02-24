module Sinbad
using JSON
using Reexport: @reexport
@reexport begin
    using Parameters, TypedTables
end

# export runEcosystem, evolveEcosystem
export runGetConfiguration

export runTEM

include("tem/runTEM.jl")
include("tools/utils.jl")
include("tools/getConfiguration.jl")

include("tools/getForcing.jl")
export getForcing

include("tem/ecoProcess.jl")
export getEcoProcess

### testing getting modules from jl files
include("Models/Models.jl")

end
