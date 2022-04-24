export gppAirT_TEM

@bounds @describe @units @with_kw struct gppAirT_TEM{T1, T2, T3} <: gppAirT
	Tmin::T1 = 5.0 | (-10.0, 15.0) | "minimum temperature at which GPP ceases" | "°C"
	Tmax::T2 = 20.0 | (10.0, 45.0) | "maximum temperature at which GPP ceases" | "°C"
	Topt::T3 = 15.0 | (5.0, 30.0) | "optimal temperature for GPP" | "°C"
end

function compute(o::gppAirT_TEM, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_TEM o
    @unpack_forcing TairDay ∈ forcing
    @unpack_land (zero, one) ∈ helpers.numbers

    ## calculate variables
    pTmin = TairDay - Tmin
    pTmax = TairDay - Tmax
    pTScGPP = pTmin * pTmax / ((pTmin * pTmax) - (TairDay - Topt)^2)
    TScGPP = (TairDay > Tmax) || (TairDay < Tmin) ? zero : pTScGPP
    TempScGPP = clamp(TScGPP, zero, one)

    ## pack land variables
    @pack_land TempScGPP => land.gppAirT
    return land
end

@doc """
temperature stress for gppPot based on TEM

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of temperature using gppAirT_TEM

*Inputs*
 - forcing.TairDay: daytime temperature [°C]

*Outputs*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gppAirT_TEM