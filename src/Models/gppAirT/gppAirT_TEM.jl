export gppAirT_TEM

#! format: off
@bounds @describe @units @with_kw struct gppAirT_TEM{T1,T2,T3} <: gppAirT
    Tmin::T1 = 5.0 | (-10.0, 15.0) | "minimum temperature at which GPP ceases" | "°C"
    Tmax::T2 = 20.0 | (10.0, 45.0) | "maximum temperature at which GPP ceases" | "°C"
    Topt::T3 = 15.0 | (5.0, 30.0) | "optimal temperature for GPP" | "°C"
end
#! format: on

function define(p_struct::gppAirT_TEM, forcing, land, helpers)
    @unpack_gppAirT_TEM p_struct
    t_two = oftype(Tmin, 2)
    ## pack land variables
    @pack_land t_two => land.gppAirT
    return land
end

function compute(p_struct::gppAirT_TEM, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_TEM p_struct
    @unpack_forcing TairDay ∈ forcing
    @unpack_land begin
        t_two ∈ land.gppAirT
        (z_zero, o_one) ∈ land.wCycleBase
    end

    ## calculate variables
    pTmin = TairDay - Tmin
    pTmax = TairDay - Tmax
    pTScGPP = pTmin * pTmax / ((pTmin * pTmax) - (TairDay - Topt)^t_two)
    TScGPP = (TairDay > Tmax) || (TairDay < Tmin) ? z_zero : pTScGPP
    gpp_f_airT = clampZeroOne(TScGPP)

    ## pack land variables
    @pack_land gpp_f_airT => land.gppAirT
    return land
end

@doc """
temperature stress for gpp_potential based on TEM

# Parameters
$(SindbadParameters)

---

# compute:
Effect of temperature using gppAirT_TEM

*Inputs*
 - forcing.TairDay: daytime temperature [°C]

*Outputs*
 - land.gppAirT.gpp_f_airT: effect of temperature on potential GPP

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
