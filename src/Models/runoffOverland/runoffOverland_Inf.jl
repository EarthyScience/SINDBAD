export runoffOverland_Inf

struct runoffOverland_Inf <: runoffOverland end

function compute(params::runoffOverland_Inf, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt inf_excess_runoff ⇐ land.fluxes

    ## calculate variables
    overland_runoff = inf_excess_runoff

    ## pack land variables
    @pack_nt overland_runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoffOverland_Inf}) = "## assumes overland flow to be infiltration excess runoff"

@doc """

$(getBaseDocString(runoffOverland_Inf))

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]  

*Created by:*
 - skoirala
"""
runoffOverland_Inf
