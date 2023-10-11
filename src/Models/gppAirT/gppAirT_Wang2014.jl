export gppAirT_Wang2014

#! format: off
@bounds @describe @units @with_kw struct gppAirT_Wang2014{T1} <: gppAirT
    Tmax::T1 = 10.0 | (5.0, 45.0) | "maximum temperature at which GPP ceases" | "°C"
end
#! format: on

function compute(params::gppAirT_Wang2014, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_Wang2014 params
    @unpack_forcing f_airT_day ∈ forcing
    @unpack_land (z_zero, o_one) ∈ land.wCycleBase

    ## calculate variables
    gpp_f_airT = clampZeroOne(f_airT_day / Tmax)

    ## pack land variables
    @pack_land gpp_f_airT => land.gppAirT
    return land
end

@doc """
temperature stress on gpp_potential based on Wang2014

# Parameters
$(SindbadParameters)

---

# compute:
Effect of temperature using gppAirT_Wang2014

*Inputs*
 - forcing.f_airT_day: daytime temperature [°C]

*Outputs*
 - land.gppAirT.gpp_f_airT: effect of temperature on potential GPP

---

# Extended help

*References*
 - Wang, H., Prentice, I. C., & Davis, T. W. (2014). Biophsyical constraints on gross  primary production by the terrestrial biosphere. Biogeosciences, 11[20], 5987.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppAirT_Wang2014
