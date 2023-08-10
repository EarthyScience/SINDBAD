module Models

# Import & export necessary modules/functions
using ..Sindbad
using FieldMetadata: @metadata
using TypedTables: Table
using Parameters: @with_kw
using StatsBase: mean
@metadata describe "" String
@metadata bounds (nothing, nothing) Tuple
@metadata units "" String
export describe, bounds, units

export sindbad_models
# export LandEcosystem

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
model_list = (:wCycleBase,
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

## create a table to view all sindbad models and their orders.
sindbad_models = Table((; model=[model_list...]))

# ## create a table to view all sindbad models and their orders.
# apprs = []
# for _mod in model_list:
# 	st = subtypes(getproperty(Sindbad, _mod))
# 	push!(apprs, join(st, ", "))
# 	# for _st in st:
# 	# 	appr = 
# end

# sindbad_models = Table((; model=[model_list...], approaches = [apprs...]))

## Import all models.
for model_name_symbol ∈ model_list
    model_name = string(model_name_symbol)
    model_path = model_name * "/" * model_name * ".jl"
    include(model_path)
end

end
