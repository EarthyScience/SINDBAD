module Models
using ..Sinbad
@metadata describe "" String
@metadata bounds (nothing, nothing) Tuple
@metadata units "" String

export getStates, rainSnow, roSat, snowMelt, sumVariables, evapSoil, transpiration, updateState
export describe, bounds, units, compute

abstract type LandEcosystem end

abstract type getStates <: LandEcosystem end
include("getStates/getStates_simple.jl")
abstract type rainSnow <: LandEcosystem end
include("rainSnow/rainSnow_Tair.jl")
abstract type roSat <: LandEcosystem end
include("roSat/roSat_Bergstroem.jl")

include("snowMelt/snowMelt.jl")

abstract type evapSoil <: LandEcosystem end
include("evapSoil/evapSoil_demSup.jl")
abstract type transpiration <: LandEcosystem end
include("transpiration/transpiration_demSup.jl")
abstract type updateState <: LandEcosystem end
include("updateState/updateState_wSimple.jl")
end
