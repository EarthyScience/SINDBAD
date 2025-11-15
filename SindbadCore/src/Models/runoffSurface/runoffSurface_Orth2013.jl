export runoffSurface_Orth2013

#! format: off
@bounds @describe @units @timescale @with_kw struct runoffSurface_Orth2013{T1} <: runoffSurface
    qt::T1 = 2.0 | (0.5, 100.0) | "delay parameter for land runoff" | "time" | ""
end
#! format: on

function define(params::runoffSurface_Orth2013, forcing, land, helpers)
    @unpack_runoffSurface_Orth2013 params

    ## Instantiate variables
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

purpose(::Type{runoffSurface_Orth2013}) = "Surface runoff directly calculated using delay coefficient for the last 60 days based on the Orth et al. (2013) method."

@doc """

$(getModelDocString(runoffSurface_Orth2013))

---

# Extended help

*References*
 - Orth, R., Koster, R. D., & Seneviratne, S. I. (2013).  Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14[6], 1773-1790.
 - used in Trautmann et al. 2018

*Versions*
 - 1.0 on 18.11.2019 [ttraut]  

*Created by*
 - ttraut

*Notes*
 - how to handle 60days?!?!
"""
runoffSurface_Orth2013
