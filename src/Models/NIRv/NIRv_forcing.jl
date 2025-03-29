export NIRv_forcing

struct NIRv_forcing <: NIRv end

function compute(params::NIRv_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_NIRv ⇐ forcing

    NIRv = f_NIRv
    
    ## pack land variables
    @pack_nt NIRv ⇒ land.states
    return land
end

purpose(::Type{NIRv_forcing}) = "sets the value of land.states.NIRv from the forcing in every time step"

@doc """

$(getBaseDocString())

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]

*Created by:*
 - sbesnard
"""
NIRv_forcing
