export gppSoilW_Stocker2020

@bounds @describe @units @with_kw struct gppSoilW_Stocker2020{T1,T2} <: gppSoilW
    q::T1 = 1.0 | (0.01, 4.0) | "sensitivity of GPP to soil moisture " | ""
    θstar::T2 = 0.6 | (0.1, 1.0) | "" | ""
end


function instantiate(o::gppSoilW_Stocker2020, forcing, land, helpers)
    SMScGPP = helpers.numbers.𝟙
    ttwo = helpers.numbers.sNT(2.0)

    ## pack land variables
    @pack_land (ttwo, SMScGPP) => land.gppSoilW
    return land
end

function compute(o::gppSoilW_Stocker2020, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_Stocker2020 o

    ## unpack land variables
    @unpack_land begin
        (s_wFC, s_wWP) ∈ land.soilWBase
        soilW ∈ land.pools
        (𝟙, 𝟘, squarer) ∈ helpers.numbers
        ttwo ∈ land.gppSoilW
    end

    ## calculate variables
    SM = sum(soilW)
    maxAWC = max(s_wFC - s_wWP, 𝟘)
    actAWC = max(SM - s_wWP, 𝟘)
    SM_nor = min(actAWC / maxAWC, 𝟙)
    tfW = -q * (SM_nor - θstar) ^ ttwo + 𝟙
    fW = SM_nor <= θstar ? tfW : 𝟙
    SMScGPP = clamp(fW, 𝟘, 𝟙)

    ## pack land variables
    @pack_land SMScGPP => land.gppSoilW
    return land
end

@doc """
soil moisture stress on gppPot based on Stocker2020

# Parameters
$(PARAMFIELDS)

---

# compute:
Gpp as a function of soilW; should be set to none if coupled with transpiration using gppSoilW_Stocker2020

*Inputs*
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.s_wWP: sum of wilting point
 - land.soilWBase.s_wFC: sum of field capacity

*Outputs*
 - land.gppSoilW.SMScGPP: soil moisture stress on gppPot (0-1)

---

# Extended help

*References*
 - Stocker, B. D., Wang, H., Smith, N. G., Harrison, S. P., Keenan, T. F., Sandoval, D., & Prentice, I. C. (2020). P-model v1. 0: an optimality-based light use efficiency model for simulating ecosystem gross primary production. Geoscientific Model Development, 13(3), 1545-1581.

*Versions*

*Created by:*
 - ncarval & Shanning Bao [sbao]

*Notes*
"""
gppSoilW_Stocker2020