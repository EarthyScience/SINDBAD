export runoffOverland_Sat

struct runoffOverland_Sat <: runoffOverland end

function compute(params::runoffOverland_Sat, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt sat_excess_runoff ⇐ land.fluxes

    ## calculate variables
    overland_runoff = sat_excess_runoff

    ## pack land variables
    @pack_nt overland_runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoffOverland_Sat}) = "assumes overland flow to be saturation excess runoff"

@doc """

$(getBaseDocString(runoffOverland_Sat))

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]  

*Created by:*
 - skoirala
"""
runoffOverland_Sat
