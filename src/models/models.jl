module Models

# Import & export necessary modules/functions
using ..Sinbad
@metadata describe "" String
@metadata bounds (nothing, nothing) Tuple
@metadata units "" String
export describe, bounds, units, sindbad_models


# Define SINDBAD supertype
abstract type LandEcosystem end

# fallback functions for precompute, compute and update. These functions here make the corresponding functions in the model (approaches) optional 
function precompute(o::LandEcosystem, forcing, land, helpers)
	return land
end

function compute(o::LandEcosystem, forcing, land, helpers)
	return land
end

function update(o::LandEcosystem, forcing, land, helpers)
	return land
end


# List all models of SINDBAD in the order they are called. Note that a new model is only executed if it is added to this list. When adding a new model, create a new copy of this jl file to work with.
model_list = (:rainSnow, :rainIntensity, :PET, :ambientCO2, :landProperties, :soilTexture, :soilProperties, :soilWBase, :getPools, :rootMaximumDepth, :rootFraction, :vegProperties, :fAPAR, :EVI, :LAI, :NDVI, :NIRv, :NDWI, :treeFraction, :vegFraction, :snowFraction, :sublimation, :snowMelt, :interception, :runoffInfiltrationExcess, :saturatedFraction, :runoffSaturationExcess, :runoffInterflow, :runoffOverland, :runoffSurface, :runoffBase, :percolation, :drainage, :capillaryFlow, :soilWFlow, :groundWRecharge, :groundWSoilWInteraction, :groundWsurfaceWInteraction, :evaporation, :transpirationDemand, :vegAvailableWater, :transpirationSupply, :gppPotential, :gppDiffRadiation, :gppDirRadiation, :gppAirT, :gppVPD, :gppDemand, :gppSoilW, :WUE, :gpp, :transpiration, :rootWaterUptake, :cCycleBase, :cCycleDisturbance, :cTauSoilT, :cTauSoilW, :cTauLAI, :cTauSoilProperties, :cTauVegProperties, :cTau, :aRespirationAirT, :cAllocationLAI, :cAllocationRadiation, :cAllocationSoilW, :cAllocationSoilT, :cAllocationNutrients, :cAllocation, :cAllocationTreeFraction, :aRespiration, :cFlowSoilProperties, :cFlowVegProperties, :cFlow, :cCycleConsistency, :cCycle, :riverRouting, :evapotranspiration, :runoff, :TWS, :waterBalance,)

# create a table to view all sindbad models and their orders.
sindbad_models = Table((; model=[model_list...]))

# Import all models.
for model_name_symbol in model_list
	model_name = string(model_name_symbol)
	model_path = model_name * "/" * model_name * ".jl"
	include(model_path)
end

end
