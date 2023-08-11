module Models

# Import & export necessary modules/functions
using ..Sindbad
using FieldMetadata: @metadata
using Parameters: @with_kw
using StatsBase: mean
@metadata describe "" String
@metadata bounds (nothing, nothing) Tuple
@metadata units "" String
export describe, bounds, units
export DoCatchModelErrors
export DontCatchModelErrors

export sindbad_models
# export LandEcosystem
# define dispatch structs for catching model errors
struct DoCatchModelErrors end
struct DontCatchModelErrors end

## Define SINDBAD supertype
abstract type LandEcosystem end



## fallback functions for instantiate, precompute, compute and update. 
## These functions here make the corresponding functions in the model (approaches) optional
function precompute(p_struct::LandEcosystem, forcing, land, helpers)
    return land
end

function define(p_struct::LandEcosystem, forcing, land, helpers)
    return land
end

function compute(p_struct::LandEcosystem, forcing, land, helpers)
    return land
end

function update(p_struct::LandEcosystem, forcing, land, helpers)
    return land
end

## List all models of SINDBAD in the order they are called. 
## Note that a new model is only executed if it is added to this list. 
## When adding a new model, create a new copy of this jl file to work with.
sindbad_models = (:wCycleBase,
    :rainSnow,
    :rainIntensity,
    :PET,
    :ambientCO2,
    :landProperties,
    :getPools,
    :soilTexture,
    :soilProperties,
    :soilWBase,
    :rootMaximumDepth,
    :rootWaterEfficiency,
    :vegProperties,
    :fAPAR,
    :EVI,
    :LAI,
    :NDVI,
    :NIRv,
    :NDWI,
    :treeFraction,
    :vegFraction,
    :snowFraction,
    :sublimation,
    :snowMelt,
    :interception,
    :runoffInfiltrationExcess,
    :saturatedFraction,
    :runoffSaturationExcess,
    :runoffInterflow,
    :runoffOverland,
    :runoffSurface,
    :runoffBase,
    :percolation,
    :evaporation,
    :drainage,
    :capillaryFlow,
    :groundWRecharge,
    :groundWSoilWInteraction,
    :groundWsurfaceWInteraction,
    :transpirationDemand,
    :vegAvailableWater,
    :transpirationSupply,
    :gppPotential,
    :gppDiffRadiation,
    :gppDirRadiation,
    :gppAirT,
    :gppVPD,
    :gppSoilW,
    :gppDemand,
    :WUE,
    :gpp,
    :transpiration,
    :rootWaterUptake,
    :cCycleBase,
    :cCycleDisturbance,
    :cTauSoilT,
    :cTauSoilW,
    :cTauLAI,
    :cTauSoilProperties,
    :cTauVegProperties,
    :cTau,
    :autoRespirationAirT,
    :cAllocationLAI,
    :cAllocationRadiation,
    :cAllocationSoilW,
    :cAllocationSoilT,
    :cAllocationNutrients,
    :cAllocation,
    :cAllocationTreeFraction,
    :autoRespiration,
    :cFlowSoilProperties,
    :cFlowVegProperties,
    :cFlow,
    :cCycleConsistency,
    :cCycle,
    :evapotranspiration,
    :runoff,
    :wCycle,
    :waterBalance,
    :deriveVariables)

## Import all models.
for model_name_symbol ∈ sindbad_models
    model_name = string(model_name_symbol)
    model_path = model_name * "/" * model_name * ".jl"
    include(model_path)
end

end
