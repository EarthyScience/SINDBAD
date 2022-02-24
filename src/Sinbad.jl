module Sinbad

using JSON
using Reexport: @reexport
@reexport begin
    using Parameters, TypedTables
end

export runEcosystem, evolveEcosystem
export SnowFrac, rainSnow, snowMelt, run, getForcing
export evapSoil, transpiration, updateState, getStates
export runGetConfiguration, setupTEM

include("tem/Ecosystem.jl")
include("tools/utils.jl")
include("tools/getConfiguration.jl")
include("tools/setupTEM.jl")

include("tools/getForcing.jl")
export getForcing

include("tem/sindbadCore.jl")
export getAllModels

### the following should come from the model structure json
include("models/getStates/getStates_simple.jl")
include("models/rainSnow/rainSnow_Tair.jl")
include("models/snowMelt/snowMelt_snowFrac.jl")
include("models/evapSoil/evapSoil_demSup.jl")
include("models/transpiration/transpiration_demSup.jl")
include("models/updateState/updateState_wSimple.jl")



# include("../tools/utils.jl")
# include("../models/rainSnow/rainSnow_Tair.jl")
# include("../models/snowMelt/snowMelt_snowFrac.jl")
# include("../models/evapSoil/evapSoil_demSup.jl")
# include("../models/transpiration/transpiration_demSup.jl")
# include("../models/updateState/updateState_wSimple.jl")

end
