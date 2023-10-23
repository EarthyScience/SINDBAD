export runoffSurface_Orth2013

#! format: off
@bounds @describe @units @with_kw struct runoffSurface_Orth2013{T1} <: runoffSurface
    qt::T1 = 2.0 | (0.5, 100.0) | "delay parameter for land runoff" | "time"
end
#! format: on

function define(params::runoffSurface_Orth2013, forcing, land, helpers)
    @unpack_runoffSurface_Orth2013 params

    ## instantiate variables
    z = exp(-((0:60) / (qt * ones(1, 61)))) - exp((((0:60) + 1) / (qt * ones(1, 61)))) # this looks to be wrong, some dots are missing
    Rdelay = z / (sum(z) * ones(1, 61))

    ## pack land variables
    @pack_nt (z, Rdelay) ⇒ land.surface_runoff
    return land
end

function compute(params::runoffSurface_Orth2013, forcing, land, helpers)
    #@needscheck and redo
    ## unpack parameters
    @unpack_runoffSurface_Orth2013 params

    ## unpack land variables
    @unpack_nt (z, Rdelay) ⇐ land.surface_runoff

    ## unpack land variables
    @unpack_nt begin
        surfaceW ⇐ land.pools
        overland_runoff ⇐ land.fluxes
    end
    # calculate delay function of previous days
    # calculate Q from delay of previous days
    if tix > 60
        tmin = maximum(tix - 60, 1)
        surface_runoff = sum(overland_runoff[tmin:tix] * Rdelay)
    else # | accumulate land runoff in surface storage
        surface_runoff = 0.0
    end
    # update the water pool

    ## pack land variables
    @pack_nt begin
        surface_runoff ⇒ land.fluxes
        Rdelay ⇒ land.surface_runoff
    end
    return land
end

function update(params::runoffSurface_Orth2013, forcing, land, helpers)
    @unpack_runoffSurface_Orth2013 params

    ## unpack variables
    @unpack_nt begin
        surfaceW ⇐ land.pools
        ΔsurfaceW ⇐ land.pools
    end

    ## update storage pools
    surfaceW .= surfaceW .+ ΔsurfaceW

    # reset ΔsurfaceW to zero
    ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW

    ## pack land variables
    @pack_nt begin
        surfaceW ⇒ land.pools
        ΔsurfaceW ⇒ land.pools
    end
    return land
end

@doc """
calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff

# Parameters
$(SindbadParameters)

---

# compute:
Runoff from surface water storages using runoffSurface_Orth2013

*Inputs*

*Outputs*
 - land.fluxes.surface_runoff : runoff from land [mm/time]
 - land.surface_runoff.Rdelay

# update

update pools and states in runoffSurface_Orth2013


# instantiate:
instantiate/instantiate time-invariant variables for runoffSurface_Orth2013


---

# Extended help

*References*
 - Orth, R., Koster, R. D., & Seneviratne, S. I. (2013).  Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14[6], 1773-1790.
 - used in Trautmann et al. 2018

*Versions*
 - 1.0 on 18.11.2019 [ttraut]  

*Created by:*
 - ttraut

*Notes*
 - how to handle 60days?!?!
"""
runoffSurface_Orth2013
