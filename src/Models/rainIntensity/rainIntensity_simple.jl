export rainIntensity_simple

#! format: off
@bounds @describe @units @timescale @with_kw struct rainIntensity_simple{T1} <: rainIntensity
    rain_init_factor::T1 = 0.04167 | (0.0, 1.0) | "factor to convert daily rainfall to rainfall intensity" | "" | ""
end
#! format: on

function compute(params::rainIntensity_simple, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_rainIntensity_simple params
    @unpack_nt f_rain ⇐ forcing

    ## calculate variables
    rain_int = f_rain * rain_init_factor

    ## pack land variables
    @pack_nt rain_int ⇒ land.states
    return land
end

purpose(::Type{rainIntensity_simple}) = "Rainfall intensity as a linear function of rainfall amount."

@doc """

$(getModelDocString(rainIntensity_simple))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: creation of approach  

*Created by*
 - skoirala | @dr-ko
"""
rainIntensity_simple
