export runoffBase_Zhang2008

#! format: off
@bounds @describe @units @with_kw struct runoffBase_Zhang2008{T1} <: runoffBase
    bc::T1 = 0.001 | (0.00001, 0.02) | "base flow coefficient" | "day-1"
end
#! format: on


function compute(p_struct::runoffBase_Zhang2008, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffBase_Zhang2008 p_struct

    ## unpack land variables
    @unpack_land begin
        groundW ∈ land.pools
        ΔgroundW ∈ land.states
        n_groundW ∈ land.wCycleBase
    end

    ## calculate variables
    # simply assume that a fraction of the GWstorage is baseflow
    base_runoff = bc * totalS(groundW, ΔgroundW)

    # update groundwater changes

    ΔgroundW = addToEachElem(ΔgroundW, -base_runoff / n_groundW)

    ## pack land variables
    @pack_land begin
        base_runoff => land.fluxes
        ΔgroundW => land.states
    end
    return land
end

function update(p_struct::runoffBase_Zhang2008, forcing, land, helpers)
    @unpack_runoffBase_Zhang2008 p_struct

    ## unpack variables
    @unpack_land begin
        groundW ∈ land.pools
        ΔgroundW ∈ land.states
    end

    ## update variables
    groundW .= groundW .+ ΔgroundW

    # reset groundwater changes to zero
    ΔgroundW .= ΔgroundW .- ΔgroundW

    # ## pack land variables
    # @pack_land begin
    # 	groundW => land.pools
    # 	# ΔgroundW => land.states
    # end
    return land
end

@doc """
computes baseflow from a linear ground water storage

# Parameters
$(SindbadParameters)

---

# compute:
Baseflow using runoffBase_Zhang2008

*Inputs*

*Outputs*
 - land.fluxes.base_runoff: base flow [mm/time]

# update

update pools and states in runoffBase_Zhang2008

 - land.pools.groundW: groundwater storage [mm]

---

# Extended help

*References*
 - Zhang, Y. Q., Chiew, F. H. S., Zhang, L., Leuning, R., & Cleugh, H. A. (2008).  Estimating catchment evaporation and runoff using MODIS leaf area index & the Penman‐Monteith equation.  Water Resources Research, 44[10].

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung
"""
runoffBase_Zhang2008
