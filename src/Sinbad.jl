module Sinbad
using JSON
using Reexport: @reexport
@reexport begin
    using Parameters, TypedTables
end

export runEcosystem, evolveEcosystem
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
