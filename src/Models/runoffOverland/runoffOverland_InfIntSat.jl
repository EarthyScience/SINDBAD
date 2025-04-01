export runoffOverland_InfIntSat

struct runoffOverland_InfIntSat <: runoffOverland end

function compute(params::runoffOverland_InfIntSat, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt (inf_excess_runoff, interflow_runoff, sat_excess_runoff) ⇐ land.fluxes

    ## calculate variables
    overland_runoff = inf_excess_runoff + interflow_runoff + sat_excess_runoff

    ## pack land variables
    @pack_nt overland_runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoffOverland_InfIntSat}) = "assumes overland flow to be sum of infiltration excess, interflow, and saturation excess runoffs"

@doc """

$(getBaseDocString(runoffOverland_InfIntSat))

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala | @dr-ko]  

*Created by*
 - skoirala | @dr-ko
"""
runoffOverland_InfIntSat
