export runoffSurface_all

struct runoffSurface_all <: runoffSurface end

function compute(params::runoffSurface_all, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt overland_runoff ⇐ land.fluxes

    ## calculate variables
    # all overland flow becomes surface runoff
    surface_runoff = overland_runoff

    ## pack land variables
    @pack_nt surface_runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoffSurface_all}) = "All overland runoff generates surface runoff."

@doc """

$(getProcessDocstring(runoffSurface_all))

---

# Extended help

*References*

*Versions*
 - 1.0 on 20.11.2019 [skoirala | @dr-ko]: combine surface_runoff_direct, Indir, suw_recharge  

*Created by*
 - skoirala | @dr-ko
"""
runoffSurface_all
