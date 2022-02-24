module Sinbad
using JSON
using Reexport: @reexport
@reexport begin
    using Parameters, TypedTables
end

include("tools/utils.jl")
include("tools/getConfiguration.jl")
export runGetConfiguration
include("tools/getForcing.jl")
export getForcing

include("tem/runTEM.jl")
export runTEM
include("tem/ecoProcess.jl")
export getEcoProcess

### testing getting modules from jl files
include("Models/Models.jl")

end
