module Models
using ..Sinbad: TerEcosystem
using ..Sinbad

export getStates, rainSnow, snowMelt, evapSoil, transpiration, updateState
export run

abstract type getStates <: TerEcosystem end
include("getStates/getStates_simple.jl")
abstract type rainSnow <: TerEcosystem end
include("rainSnow/rainSnow_Tair.jl")
include("rainSnow/rainSnow_simpleorwhatever.jl")
abstract type snowMelt <: TerEcosystem end
include("snowMelt/snowMelt_snowFrac.jl")
abstract type evapSoil <: TerEcosystem end
include("evapSoil/evapSoil_demSup.jl")
abstract type transpiration <: TerEcosystem end
include("transpiration/transpiration_demSup.jl")
abstract type updateState <: TerEcosystem end
include("updateState/updateState_wSimple.jl")

end