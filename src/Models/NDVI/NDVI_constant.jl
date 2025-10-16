export NDVI_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct NDVI_constant{T1} <: NDVI
    constant_NDVI::T1 = 1.0 | (0.0, 1.0) | "NDVI" | "" | ""
end
#! format: on

function precompute(params::NDVI_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_NDVI_constant params

    ## calculate variables
    NDVI = constant_NDVI

    ## pack land variables
    @pack_nt NDVI ⇒ land.states
    return land
end

purpose(::Type{NDVI_constant}) = "Sets NDVI as a constant value."

@doc """

$(getModelDocString(NDVI_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by*
 - sbesnard
"""
NDVI_constant
