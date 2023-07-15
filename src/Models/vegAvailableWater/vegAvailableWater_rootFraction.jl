export vegAvailableWater_rootFraction

struct vegAvailableWater_rootFraction <: vegAvailableWater end

function define(p_struct::vegAvailableWater_rootFraction, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        soilW ∈ land.pools
    end

    PAW = zero(soilW)

    ## pack land variables
    @pack_land PAW => land.vegAvailableWater
    return land
end

function compute(p_struct::vegAvailableWater_rootFraction, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        p_wWP ∈ land.soilWBase
        p_frac_root_to_soil_depth ∈ land.rootFraction
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        PAW ∈ land.vegAvailableWater
    end
    for sl ∈ eachindex(soilW)
        PAW_sl = p_frac_root_to_soil_depth[sl] * (max_0(soilW[sl] + ΔsoilW[sl] - p_wWP[sl]))
        @rep_elem PAW_sl => (PAW, sl, :soilW)
    end

    @pack_land PAW => land.vegAvailableWater
    return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants

---

# compute:
Plant available water using vegAvailableWater_rootFraction

*Inputs*
 - land.pools.soilW
 - land.rootFraction.constant_frac_root_to_soil_depth
 - land.states.maxRootD

*Outputs*
 - land.rootFraction.p_frac_root_to_soil_depth
 - land.states.PAW

---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
vegAvailableWater_rootFraction
