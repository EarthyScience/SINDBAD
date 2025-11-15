export runoffBase_Zhang2008

#! format: off
@bounds @describe @units @timescale @with_kw struct runoffBase_Zhang2008{T1} <: runoffBase
    k_baseflow::T1 = 0.001 | (0.00001, 0.02) | "base flow coefficient" | "day-1" | "day"
end
#! format: on


function compute(params::runoffBase_Zhang2008, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffBase_Zhang2008 params

    ## unpack land variables
    @unpack_nt begin
        groundW ⇐ land.pools
        ΔgroundW ⇐ land.pools
        n_groundW = groundW ⇐ helpers.pools.n_layers
    end

    ## calculate variables
    # simply assume that a fraction of the GWstorage is baseflow
    base_runoff = k_baseflow * totalS(groundW, ΔgroundW)

    # update groundwater changes

    ΔgroundW = addToEachElem(ΔgroundW, -base_runoff / n_groundW)

    ## pack land variables
    @pack_nt begin
        base_runoff ⇒ land.fluxes
        ΔgroundW ⇒ land.pools
    end
    return land
end

purpose(::Type{runoffBase_Zhang2008}) = "Baseflow from a linear groundwater storage following Zhang (2008)."

@doc """

$(getModelDocString(runoffBase_Zhang2008))

---

# Extended help

*References*
 - Zhang, Y. Q., Chiew, F. H. S., Zhang, L., Leuning, R., & Cleugh, H. A. (2008).  Estimating catchment evaporation and runoff using MODIS leaf area index & the Penman‐Monteith equation.  Water Resources Research, 44[10].

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by*
 - mjung
"""
runoffBase_Zhang2008
