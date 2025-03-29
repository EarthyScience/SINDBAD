export rootWaterUptake_topBottom

struct rootWaterUptake_topBottom <: rootWaterUptake end

function define(params::rootWaterUptake_topBottom, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        soilW ⇐ land.pools
    end
    root_water_uptake = zero(soilW)

    ## pack land variables
    @pack_nt begin
        root_water_uptake ⇒ land.fluxes
    end
    return land
end

function compute(params::rootWaterUptake_topBottom, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        PAW ⇐ land.states
        soilW ⇐ land.pools
        (ΔsoilW, root_water_uptake) ⇐ land.states
        transpiration ⇐ land.fluxes
        z_zero ⇐ land.constants
    end
    to_uptake = oftype(eltype(PAW), transpiration)

    for sl ∈ eachindex(land.pools.soilW)
        uptake_from_layer = min(to_uptake, PAW[sl])
        @rep_elem uptake_from_layer ⇒ (root_water_uptake, sl, :soilW)
        @add_to_elem -root_water_uptake[sl] ⇒ (ΔsoilW, sl, :soilW)
        to_uptake = to_uptake - uptake_from_layer
    end

    ## pack land variables
    @pack_nt begin
        root_water_uptake ⇒ land.fluxes
        ΔsoilW ⇒ land.pools
    end
    return land
end

function update(params::rootWaterUptake_topBottom, forcing, land, helpers)

    ## unpack variables
    @unpack_nt begin
        soilW ⇐ land.pools
        ΔsoilW ⇐ land.pools
    end

    ## update variables
    # update soil moisture
    soilW .= soilW .+ ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW .= ΔsoilW .- ΔsoilW

    ## pack land variables
    @pack_nt begin
        soilW ⇒ land.pools
        ΔsoilW ⇒ land.pools
    end
    return land
end

purpose(::Type{rootWaterUptake_topBottom}) = "rootUptake from each of the soil layer from top to bottom using all water in each layer"

@doc """

$(getBaseDocString())

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
