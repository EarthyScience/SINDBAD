export rainIntensity_simple

#! format: off
@bounds @describe @units @with_kw struct rainIntensity_simple{T1} <: rainIntensity
    rain_init_factor::T1 = 0.04167 | (0.0, 1.0) | "factor to convert daily rainfall to rainfall intensity" | ""
end
#! format: on

function compute(params::rainIntensity_simple, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_rainIntensity_simple params
    @unpack_forcing f_rain ∈ forcing

    ## calculate variables
    rain_int = f_rain * rain_init_factor

    ## pack land variables
    @pack_land rain_int => land.states
    return land
end

@doc """
stores the time series of rainfall intensity

# Parameters
$(SindbadParameters)

---

# compute:
Set rainfall intensity using rainIntensity_simple

*Inputs*
 - forcing.f_rain

*Outputs*
 - land.states.rainInt: Intesity of rainfall during the day

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainIntensity_simple
