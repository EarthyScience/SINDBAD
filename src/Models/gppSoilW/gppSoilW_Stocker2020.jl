export gppSoilW_Stocker2020

#! format: off
@bounds @describe @units @timescale @with_kw struct gppSoilW_Stocker2020{T1,T2} <: gppSoilW
    q::T1 = 1.0 | (0.01, 4.0) | "sensitivity of GPP to soil moisture " | "" | ""
    θstar::T2 = 0.6 | (0.1, 1.0) | "" | "" | ""
end
#! format: on

function define(params::gppSoilW_Stocker2020, forcing, land, helpers)
    @unpack_gppSoilW_Stocker2020 params
    gpp_f_soilW = one(q)

    ## pack land variables
    @pack_nt gpp_f_soilW ⇒ land.diagnostics
    return land
end

function compute(params::gppSoilW_Stocker2020, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_Stocker2020 params

    ## unpack land variables
    @unpack_nt begin
        (∑w_fc, ∑w_wp) ⇐ land.properties
        soilW ⇐ land.pools
        (z_zero, o_one, t_two) ⇐ land.constants
    end
    ## calculate variables
    SM = sum(soilW)
    max_AWC = maxZero(∑w_fc - ∑w_wp)
    actAWC = maxZero(SM - ∑w_wp)
    SM_nor = minOne(actAWC / max_AWC)
    tf_soilW = -q * (SM_nor - θstar)^t_two + o_one
    tmp_f_soilW = SM_nor <= θstar ? tf_soilW : one(tf_soilW)
    gpp_f_soilW = clampZeroOne(tmp_f_soilW)

    ## pack land variables
    @pack_nt gpp_f_soilW ⇒ land.diagnostics
    return land
end

@doc """
soil moisture stress on gpp_potential based on Stocker2020

# Parameters
$(SindbadParameters)

---

# compute:
Gpp as a function of soilW; should be set to none if coupled with transpiration using gppSoilW_Stocker2020

*Inputs*
 - land.pools.soilW: values of soil moisture current time step
 - land.properties.∑w_wp: sum of wilting point
 - land.properties.∑w_fc: sum of field capacity

*Outputs*
 - land.diagnostics.gpp_f_soilW: soil moisture stress on gpp_potential (0-1)

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
