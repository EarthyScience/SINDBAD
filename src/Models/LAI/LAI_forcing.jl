export LAI_forcing

struct LAI_forcing <: LAI end

function compute(params::LAI_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_LAI ⇐ forcing

    LAI = f_LAI
    ## pack land variables
    @pack_nt LAI ⇒ land.states
    return land
end

purpose(::Type{LAI_forcing}) = "sets the value of land.states.LAI from the forcing in every time step"

@doc """

$(getBaseDocString(LAI_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: moved LAI from land.LAI.LAI to land.states.LAI  

*Created by:*
 - skoirala
"""
LAI_forcing
