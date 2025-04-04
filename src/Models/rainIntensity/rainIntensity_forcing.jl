export rainIntensity_forcing

struct rainIntensity_forcing <: rainIntensity end

function compute(params::rainIntensity_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_rain_int ⇐ forcing

    rain_int = f_rain_int

    ## pack land variables
    @pack_nt rain_int ⇒ land.states
    return land
end

purpose(::Type{rainIntensity_forcing}) = "stores the time series of rainfall & snowfall from forcing"

@doc """

$(getBaseDocString(rainIntensity_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: creation of approach  

*Created by*
 - skoirala | @dr-ko
"""
rainIntensity_forcing
