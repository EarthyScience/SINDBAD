module Models

# Import & export necessary modules/functions
using ..Sindbad
using FieldMetadata: @metadata
using Parameters: @with_kw
using StatsBase: mean
@metadata timescale "" String
@metadata describe "" String
@metadata bounds (-Inf, Inf) Tuple
@metadata units "" String
export describe, bounds, units
export DoCatchModelErrors
export DoNotCatchModelErrors
export @describe, @bounds, @units, @timescale
export @with_kw
export sindbad_models
# define dispatch structs for catching model errors
struct DoCatchModelErrors end
struct DoNotCatchModelErrors end



## fallback functions for instantiate, precompute, compute and update. 
## These functions here make the corresponding functions in the model (approaches) optional
function compute(params::LandEcosystem, forcing, land, helpers)
    return land
end

function define(params::LandEcosystem, forcing, land, helpers)
    return land
end

function precompute(params::LandEcosystem, forcing, land, helpers)
    return land
end

function update(params::LandEcosystem, forcing, land, helpers)
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
    :getPools,
    :soilTexture,
    :soilProperties,
    :soilWBase,
    :rootMaximumDepth,
    :rootWaterEfficiency,
    :PFT,
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
    :groundWSurfaceWInteraction,
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
    model_path = joinpath(model_name, model_name * ".jl")
    include(model_path)
end

end
