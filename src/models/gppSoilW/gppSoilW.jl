export gppSoilW
"""
Gpp as a function of wsoil; should be set to none if coupled with transpiration

# Approaches:
 - CASA: initialized in teh preallocation function. is not VPD effect; is the ET/PET effect if Tair <= 0.0 | PET <= 0.0; use the previous stress index otherwise; compute according to CASA
 - GSI: calculate the soil moisture stress on gpp based on GSI implementation of LPJ
 - Keenan2009: calculate the soil moisture stress on gpp
 - none: set the soil moisture stress on gppPot to ones (no stress)
 - Stocker2020: calculate the soil moisture stress on gpp
"""
abstract type gppSoilW <: LandEcosystem end
include("gppSoilW_CASA.jl")
include("gppSoilW_GSI.jl")
include("gppSoilW_Keenan2009.jl")
include("gppSoilW_none.jl")
include("gppSoilW_Stocker2020.jl")
