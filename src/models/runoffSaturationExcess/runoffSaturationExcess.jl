export runoffSaturationExcess
"""
Saturation runoff

# Approaches:
 - Bergstroem: 
 - Bergstroem1992MixedVegFraction: calculates land surface runoff & infiltration to different soil layers
 - Bergstroem1992VegFraction: calculates land surface runoff & infiltration to different soil layers using
 - Bergstroem1992VegFractionFroSoil: calculates land surface runoff & infiltration to different soil layers using. calculates land surface runoff & infiltration to different soil layers using
 - Bergstroem1992VegFractionPFT: calculates land surface runoff & infiltration to different soil layers using. calculates land surface runoff & infiltration to different soil layers using
 - none: set the saturation excess runoff to zeros
 - wSoilSatFraction: calculate the saturation excess runoff as a fraction of
 - Zhang2008: calculate the saturation excess runoff as a fraction of incoming water
"""
abstract type runoffSaturationExcess <: LandEcosystem end
include("runoffSaturationExcess_Bergstroem.jl")
include("runoffSaturationExcess_Bergstroem1992MixedVegFraction.jl")
include("runoffSaturationExcess_Bergstroem1992VegFraction.jl")
include("runoffSaturationExcess_Bergstroem1992VegFractionFroSoil.jl")
include("runoffSaturationExcess_Bergstroem1992VegFractionPFT.jl")
include("runoffSaturationExcess_none.jl")
include("runoffSaturationExcess_wSoilSatFraction.jl")
include("runoffSaturationExcess_Zhang2008.jl")
