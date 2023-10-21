export rootWaterUptake_proportion

struct rootWaterUptake_proportion <: rootWaterUptake end

function define(params::rootWaterUptake_proportion, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        soilW ∈ land.pools
    end
    root_water_uptake = zero(soilW)

    ## pack land variables
    @pack_land begin
        root_water_uptake → land.fluxes
    end
    return land
end

function compute(params::rootWaterUptake_proportion, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        PAW ∈ land.states
        (soilW, ΔsoilW) ∈ land.pools
        transpiration ∈ land.fluxes
        root_water_uptake ∈ land.fluxes
        (z_zero, o_one) ∈ land.constants
        tolerance ∈ helpers.numbers
    end
    # get the transpiration
    # to_uptake = o_one * transpiration
    PAWTotal = sum(PAW)
    to_uptake = maxZero(oftype(PAWTotal, transpiration))

    # extract from top to bottom
    for sl ∈ eachindex(land.pools.soilW)
        uptake_proportion = to_uptake * getFrac(PAW[sl], PAWTotal)
        @rep_elem uptake_proportion → (root_water_uptake, sl, :soilW)
        @add_to_elem -root_water_uptake[sl] → (ΔsoilW, sl, :soilW)
    end
    # pack land variables
    @pack_land begin
        root_water_uptake → land.fluxes
        ΔsoilW → land.pools
    end
    return land
end

function update(params::rootWaterUptake_proportion, forcing, land, helpers)

    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.pools
    end

    ## update variables
    # update soil moisture
    soilW .= soilW .+ ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW .= ΔsoilW .- ΔsoilW

    ## pack land variables
    @pack_land begin
        soilW → land.pools
        # ΔsoilW → land.pools
    end
    return land
end

@doc """
rootUptake from each soil layer proportional to the relative plant water availability in the layer

---

# compute:
Root water uptake (extract water from soil) using rootWaterUptake_proportion

*Inputs*
 - land.fluxes.transpiration: actual transpiration
 - land.pools.soilW: soil moisture
 - land.states.PAW: plant available water

*Outputs*
 - land.states.root_water_uptake: moisture uptake from each soil layer [nZix of soilW]

# update

update pools and states in rootWaterUptake_proportion

 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 13.03.2020 [ttraut]

*Created by:*
 - ttraut

*Notes*
 - assumes that the uptake from each layer remains proportional to the root fraction
"""
rootWaterUptake_proportion
