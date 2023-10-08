export rainIntensity_forcing

struct rainIntensity_forcing <: rainIntensity end

function compute(p_struct::rainIntensity_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing f_rain_int ∈ forcing

    rain_int = f_rain_int

    ## pack land variables
    @pack_land rain_int => land.states
    return land
end

@doc """
stores the time series of rainfall & snowfall from forcing

---

# compute:
Set rainfall intensity using rainIntensity_forcing

*Inputs*
 - land.states.rainInt

*Outputs*
 - land.states.rainInt: liquid rainfall from forcing input  threshold
 - forcing.Snow using the snowfall scaling parameter which can be optimized

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainIntensity_forcing
