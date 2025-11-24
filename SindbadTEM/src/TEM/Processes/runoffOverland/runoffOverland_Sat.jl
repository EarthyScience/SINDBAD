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

purpose(::Type{runoffOverland_Sat}) = "Overland flow due to saturation excess runoff."

@doc """

$(getProcessDocstring(runoffOverland_Sat))

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala | @dr-ko]  

*Created by*
 - skoirala | @dr-ko
"""
runoffOverland_Sat
