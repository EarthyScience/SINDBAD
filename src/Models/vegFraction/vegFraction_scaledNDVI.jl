export vegFraction_scaledNDVI

#! format: off
@bounds @describe @units @timescale @with_kw struct vegFraction_scaledNDVI{T1} <: vegFraction
    NDVIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for NDVI" | "" | ""
end
#! format: on

function compute(params::vegFraction_scaledNDVI, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_scaledNDVI params

    ## unpack land variables
    @unpack_nt begin
        NDVI ⇐ land.states
    end

    ## calculate variables
    frac_vegetation = clampZeroOne(NDVI * NDVIscale)

    ## pack land variables
    @pack_nt frac_vegetation ⇒ land.states
    return land
end

purpose(::Type{vegFraction_scaledNDVI}) = "sets the value of frac_vegetation by scaling the NDVI value"

@doc """

$(getBaseDocString(vegFraction_scaledNDVI))

---

# Extended help

*References*

*Versions*
 - 1.1 on 29.04.2020 [sbesnard]: new module  

*Created by*
 - sbesnard
"""
vegFraction_scaledNDVI
