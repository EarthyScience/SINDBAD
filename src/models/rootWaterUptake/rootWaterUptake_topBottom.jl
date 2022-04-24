export rootWaterUptake_topBottom

struct rootWaterUptake_topBottom <: rootWaterUptake
end

function compute(o::rootWaterUptake_topBottom, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (PAW, wRootUptake) ∈ land.states
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        transpiration ∈ land.fluxes
    end
    # get the transpiration
    toUptake = transpiration
    for sl in 1:length(land.pools.soilW)
        uptaken = minimum(toUptake, PAW[sl])
        wRootUptake[sl] = uptaken
        toUptake = toUptake - uptaken
        ΔsoilW[sl] = ΔsoilW[sl] - wRootUptake[sl]
    end

    ## pack land variables
    @pack_land begin
        wRootUptake => land.states
        ΔsoilW => land.states
    end
    return land
end

function update(o::rootWaterUptake_topBottom, forcing, land, helpers)

    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
    end

    ## update variables
    # update soil moisture
    soilW = soilW + ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW = ΔsoilW - ΔsoilW

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
 - land.states.PAW: plant available water [pix, zix]

*Outputs*
 - land.states.wRootUptake: moisture uptake from each soil layer [nPix, nZix of soilW]

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