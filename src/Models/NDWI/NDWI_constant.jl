export NDWI_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct NDWI_constant{T1} <: NDWI
    constant_NDWI::T1 = 1.0 | (0.0, 1.0) | "NDWI" | "" | ""
end
#! format: on

function precompute(params::NDWI_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_NDWI_constant params

    ## calculate variables
    NDWI = constant_NDWI

    ## pack land variables
    @pack_nt NDWI ⇒ land.states
    return land
end

purpose(::Type{NDWI_constant}) = "sets NDWI as a constant"

@doc """

$(getModelDocString(NDWI_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by*
 - sbesnard
"""
NDWI_constant
