module Models
using ..Sinbad

export getStates, rainSnow, roSat, snowMelt, evapSoil, transpiration, updateState

abstract type LandEcosystem end

abstract type getStates <: LandEcosystem end
include("getStates/getStates_simple.jl")
abstract type rainSnow <: LandEcosystem end
include("rainSnow/rainSnow_Tair.jl")
abstract type roSat <: LandEcosystem end
include("roSat/roSat_Bergstroem.jl")
abstract type snowMelt <: LandEcosystem end
include("snowMelt/snowMelt_snowFrac.jl")
abstract type evapSoil <: LandEcosystem end
include("evapSoil/evapSoil_demSup.jl")
abstract type transpiration <: LandEcosystem end
include("transpiration/transpiration_demSup.jl")
abstract type updateState <: LandEcosystem end
include("updateState/updateState_wSimple.jl")

end