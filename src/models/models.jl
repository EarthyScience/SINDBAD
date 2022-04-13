module Models
using ..Sinbad

@metadata describe "" String
@metadata bounds (nothing, nothing) Tuple
@metadata units "" String
export describe, bounds, units, sindbad_models

abstract type LandEcosystem end

model_list = (:rainSnow, :rainIntensity, :PET, :ambientCO2, :getPools, :landProperties, :soilTexture, :soilProperties, :soilWBase, :rootMaximumDepth, :rootFraction, :vegProperties, :fAPAR, :EVI, :LAI, :NDVI, :NIRv, :NDWI, :treeFraction, :vegFraction, :snowFraction, :sublimation, :snowMelt, :interception, :runoffInfiltrationExcess, :saturatedFraction, :runoffSaturationExcess, :runoffInterflow, :runoffOverland, :runoffSurface, :runoff, :percolation, :evaporation, :drainage, :groundWRecharge, :groundWSoilWInteraction, :capillaryFlow, :groundWsurfaceWInteraction, :runoffBase, :vegAvailableWater, :gppPotential, :gppDiffRadiation, :gppDirRadiation, :gppAirT, :gppVPD, :gppDemand, :gppSoilW, :transpirationDemand, :transpirationSupply, :WUE, :gpp, :transpiration, :evapotranspiration, :rootWaterUptake, :cCycleBase, :cCycleDisturbance, :cTauSoilT, :cTauSoilW, :cTauLAI, :cTauSoilProperties, :cTauVegProperties, :cTau, :aRespirationAirT, :cAllocationLAI, :cAllocationRadiation, :cAllocationSoilW, :cAllocationSoilT, :cAllocationNutrients, :cAllocation, :cAllocationTreeFraction, :aRespiration, :cFlowSoilProperties, :cFlowVegProperties, :cFlow, :cCycleConsistency, :cCycle, :riverRouting, :TWS, :waterBalance,)

sindbad_models = Table((; model=[model_list...]))

for model_name_symbol in model_list
	model_name = string(model_name_symbol)
	model_path = model_name * "/" * model_name * ".jl"
	include(model_path)
end


function update(o<:LandEcosystem, forcing, land, infotem)
	# @unpack_cTauVegProperties_CASA o
	return land
end

end
