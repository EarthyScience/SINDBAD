export vegAvailableWater_rootWaterEfficiency

struct vegAvailableWater_rootWaterEfficiency <: vegAvailableWater end

function define(p_struct::vegAvailableWater_rootWaterEfficiency, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        soilW ∈ land.pools
    end

    PAW = zero(soilW)

    ## pack land variables
    @pack_land PAW => land.vegAvailableWater
    return land
end

function compute(p_struct::vegAvailableWater_rootWaterEfficiency, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        p_wWP ∈ land.soilWBase
        root_water_efficiency ∈ land.rootWaterEfficiency
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        PAW ∈ land.vegAvailableWater
    end
    for sl ∈ eachindex(soilW)
        PAW_sl = root_water_efficiency[sl] * (max_0(soilW[sl] + ΔsoilW[sl] - p_wWP[sl]))
        @rep_elem PAW_sl => (PAW, sl, :soilW)
    end

    @pack_land PAW => land.vegAvailableWater
    return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants

---

# compute:
Plant available water using vegAvailableWater_rootWaterEfficiency

*Inputs*
 - land.pools.soilW
 - land.rootWaterEfficiency.constant_root_water_efficiency
 - land.states.maxRootD

*Outputs*
 - land.rootWaterEfficiency.root_water_efficiency
 - land.states.PAW

---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
vegAvailableWater_rootWaterEfficiency
