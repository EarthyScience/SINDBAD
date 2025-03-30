export fAPAR_forcing

struct fAPAR_forcing <: fAPAR end

function compute(params::fAPAR_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_fAPAR ⇐ forcing

    fAPAR = f_fAPAR

    ## pack land variables
    @pack_nt fAPAR ⇒ land.states
    return land
end

purpose(::Type{fAPAR_forcing}) = "sets the value of land.states.fAPAR from the forcing in every time step"

@doc """

$(getBaseDocString(fAPAR_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 23.11.2019 [skoirala]: new approach  

*Created by*
 - skoirala
"""
fAPAR_forcing
