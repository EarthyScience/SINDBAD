module Sinbad

using ModelParameters
using Setfield
using Unitful
using Reexport: @reexport
@reexport begin
    using ModelParameters: Model, Param
end

export rainSnow, snowMelt, snowMeltSimple, runEcosystem
export run!, updateState, ecosystem, addForcing!, getForcingVars

include("model/models/rainSnow/rainSnow.jl")
include("model/models/snowMelt/snowMelt.jl")
include("model/models/snowMelt/snowMeltSimple.jl")
include("model/ecosystem.jl")
include("utils.jl")
end
