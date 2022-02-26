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
include("tools/getObservation.jl")
export getObservation

include("tem/runTEM.jl")
export runTEM, runSpinupTEM, runForwardTEM
include("tem/ecoProcess.jl")
export getEcoProcess

# include("optimization/optimizeTEM.jl")
# export optimizeTEM

### testing getting modules from jl files
include("Models/Models.jl")
export Models

end
