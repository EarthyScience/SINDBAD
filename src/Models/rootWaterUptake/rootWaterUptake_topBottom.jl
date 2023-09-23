export rootWaterUptake_topBottom

struct rootWaterUptake_topBottom <: rootWaterUptake end

function define(p_struct::rootWaterUptake_topBottom, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        soilW ∈ land.pools
    end
    root_water_uptake = zero(soilW)

    ## pack land variables
    @pack_land begin
        root_water_uptake => land.states
    end
    return land
end

function compute(p_struct::rootWaterUptake_topBottom, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        PAW ∈ land.states
        soilW ∈ land.pools
        (ΔsoilW, root_water_uptake) ∈ land.states
        transpiration ∈ land.fluxes
        z_zero ∈ land.wCycleBase
    end
    root_water_uptake .= z_zero
    # get the transpiration
    to_uptake = transpiration
    for sl ∈ eachindex(land.pools.soilW)
        root_water_uptake[sl] = min(to_uptake, PAW[sl])
        to_uptake = to_uptake - root_water_uptake[sl]
        ΔsoilW[sl] = ΔsoilW[sl] - root_water_uptake[sl]
    end

    ## pack land variables
    @pack_land begin
        root_water_uptake => land.states
        ΔsoilW => land.states
    end
    return land
end

function update(p_struct::rootWaterUptake_topBottom, forcing, land, helpers)

    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
    end

    ## update variables
    # update soil moisture
    soilW .= soilW .+ ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW .= ΔsoilW .- ΔsoilW

    ## pack land variables
    @pack_land begin
        soilW => land.pools
        ΔsoilW => land.states
    end
    return land
end

@doc """
rootUptake from each of the soil layer from top to bottom using all water in each layer

---

# compute:
Root water uptake (extract water from soil) using rootWaterUptake_topBottom

*Inputs*
 - land.fluxes.transpiration: actual transpirationiration
 - land.pools.soilW: soil moisture
 - land.states.PAW: plant available water

*Outputs*
 - land.states.root_water_uptake: moisture uptake from each soil layer [nPix, nZix of soilW]

# update

update pools and states in rootWaterUptake_topBottom

 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala

*Notes*
 - assumes that the uptake is prioritized from top to bottom; irrespective of root fraction of the layers
"""
rootWaterUptake_topBottom
