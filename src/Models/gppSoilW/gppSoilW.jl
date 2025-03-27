export gppSoilW

abstract type gppSoilW <: LandEcosystem end

include("gppSoilW_CASA.jl")
include("gppSoilW_GSI.jl")
include("gppSoilW_Keenan2009.jl")
include("gppSoilW_none.jl")
include("gppSoilW_Stocker2020.jl")

@doc """
Gpp as a function of soilW; should be set to none if coupled with transpiration

# Approaches:
 - CASA: soil moisture stress on gpp_potential based on base stress and relative ratio of PET and PAW (CASA)
 - GSI: soil moisture stress on gpp_potential based on GSI implementation of LPJ
 - Keenan2009: soil moisture stress on gpp_potential based on Keenan2009
 - none: sets the soil moisture stress on gpp_potential to one (no stress)
 - Stocker2020: soil moisture stress on gpp_potential based on Stocker2020
"""
gppSoilW
