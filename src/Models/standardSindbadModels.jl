export standard_sindbad_models
export all_available_sindbad_models


# List all models of SINDBAD in the order they would be normally be called. 
# ? Let's not do this ? And better be consistent and get the order from the model_structure.json file
# ? But, if we most then, some guidelines of where to include new ones would be helpful.
# When adding a new model, create a new copy of this jl file to work with.
# ? Relying on this hinders the addition of new models at will by new users.

"""
    standard_sindbad_models


Default ordered list of SINDBAD models
"""
standard_sindbad_models = (:wCycleBase,
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
    :plantForm,
    :treeFraction,
    :EVI,
    :vegFraction,
    :fAPAR,
    :LAI,
    :NDVI,
    :NIRv,
    :NDWI,
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
    :cVegetationDieOff,
    :cFireBurnedArea,
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
    :cFireCombustionCompleteness,
    :cFireMortality,
    :cBiomass,
    :deriveVariables)

"""
a tuple of all available SINDBAD models
"""
all_available_sindbad_models = Tuple(subtypes(LandEcosystem))
