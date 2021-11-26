module Sinbad

using ModelParameters
using Setfield
using Unitful
using Reexport: @reexport
@reexport begin
    using ModelParameters: Model, Param
end

export rainSnow, snowMelt, run!, updateState, ecosystem

include("model/models/rainSnow/rainSnow.jl")
include("model/models/snowMelt/snowMelt.jl")
include("utils.jl")
end
