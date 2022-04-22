export runoffSaturationExcess

abstract type runoffSaturationExcess <: LandEcosystem end

include("runoffSaturationExcess_Bergstroem1992.jl")
include("runoffSaturationExcess_Bergstroem1992MixedVegFraction.jl")
include("runoffSaturationExcess_Bergstroem1992VegFraction.jl")
include("runoffSaturationExcess_Bergstroem1992VegFractionFroSoil.jl")
include("runoffSaturationExcess_Bergstroem1992VegFractionPFT.jl")
include("runoffSaturationExcess_none.jl")
include("runoffSaturationExcess_satFraction.jl")
include("runoffSaturationExcess_Zhang2008.jl")

@doc """
Saturation runoff

# Approaches:
 - Bergstroem1992: saturation excess runoff using original Bergström method
 - Bergstroem1992MixedVegFraction: saturation excess runoff using Bergström method with separate berg parameters for vegetated and non-vegetated fractions
 - Bergstroem1992VegFraction: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction
 - Bergstroem1992VegFractionFroSoil: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and frozen soil fraction
 - Bergstroem1992VegFractionPFT: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and PFT
 - none: set the saturation excess runoff to zero
 - satFraction: saturation excess runoff as a fraction of saturated fraction of land
 - Zhang2008: saturation excess runoff as a function of incoming water and PET
"""
runoffSaturationExcess