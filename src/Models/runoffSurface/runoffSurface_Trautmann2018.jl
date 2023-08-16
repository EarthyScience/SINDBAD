export runoffSurface_Trautmann2018

#! format: off
@bounds @describe @units @with_kw struct runoffSurface_Trautmann2018{T1} <: runoffSurface
    qt::T1 = 2.0 | (0.5, 100.0) | "delay parameter for land runoff" | "time"
end
#! format: on

function define(p_struct::runoffSurface_Trautmann2018, forcing, land, helpers)
    @unpack_runoffSurface_Trautmann2018 p_struct

    ## instantiate variables
    z = exp(-((0:60) / (qt * ones(1, 61)))) - exp((((0:60) + 1) / (qt * ones(1, 61)))) # this looks to be wrong, some dots are missing
    Rdelay = z / (sum(z) * ones(1, 61))

    ## pack land variables
    @pack_land (z, Rdelay) => land.surface_runoff
    return land
end

function compute(p_struct::runoffSurface_Trautmann2018, forcing, land, helpers)
    #@needscheck and redo
    ## unpack parameters
    @unpack_runoffSurface_Trautmann2018 p_struct

    ## unpack land variables
    @unpack_land (z, Rdelay) ∈ land.surface_runoff

    ## unpack land variables
    @unpack_land begin
        (rain, snow) ∈ land.fluxes
        (snowW, snowW_prev, soilW, soilW_prev, surfaceW) ∈ land.pools
        (evaporation, overland_runoff, sublimation) ∈ land.fluxes
    end
    # calculate delay function of previous days
    # calculate Q from delay of previous days
    if tix > 60
        tmin = maximum(tix - 60, 1)
        surface_runoff = sum(overland_runoff[tmin:tix] * Rdelay)
        # calculate surfaceW[1] by water balance
        delSnow = sum(snowW) - sum(snowW_prev)
        input = rain + snow
        loss = evaporation + sublimation + surface_runoff
        delSoil = sum(soilW) - sum(soilW_prev)
        dSurf = input - loss - delSnow - delSoil
    else
        surface_runoff = 0.0
        dSurf = overland_runoff
    end

    ## pack land variables
    @pack_land begin
        surface_runoff => land.fluxes
        (Rdelay, dSurf) => land.surface_runoff
    end
    return land
end

function update(p_struct::runoffSurface_Trautmann2018, forcing, land, helpers)
    @unpack_runoffSurface_Trautmann2018 p_struct

    ## unpack variables
    @unpack_land begin
        surfaceW ∈ land.pools
        ΔsurfaceW ∈ land.states
    end

    ## update storage pools
    surfaceW .= surfaceW .+ ΔsurfaceW

    # reset ΔsurfaceW to zero
    ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW

    ## pack land variables
    @pack_land begin
        surfaceW => land.pools
        ΔsurfaceW => land.states
    end
    return land
end

@doc """
calculates the delay coefficient of first 60 days as a precomputation based on Orth et al. 2013 & as it is used in Trautmannet al. 2018. calculates the base runoff based on Orth et al. 2013 & as it is used in Trautmannet al. 2018

# Parameters
$(SindbadParameters)

---

# compute:
Runoff from surface water storages using runoffSurface_Trautmann2018

*Inputs*

*Outputs*
 - land.fluxes.surface_runoff : runoff from land [mm/time]
 - land.surface_runoff.Rdelay

# update

update pools and states in runoffSurface_Trautmann2018


# instantiate:
instantiate/instantiate time-invariant variables for runoffSurface_Trautmann2018


---

# Extended help

*References*
 - Orth, R., Koster, R. D., & Seneviratne, S. I. (2013).  Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14[6], 1773-1790.
 - used in Trautmann et al. 2018

*Versions*
 - 1.0 on 18.11.2019 [ttraut]  
 - 1.1 on 21.01.2020 [ttraut] : calculate surfaceW[1] based on water balance  (1:1 as in TWS Paper)

*Created by:*
 - ttraut

*Notes*
 - how to handle 60days?!?!
"""
runoffSurface_Trautmann2018
