export vegFraction_scaledNDVI

#! format: off
@bounds @describe @units @with_kw struct vegFraction_scaledNDVI{T1} <: vegFraction
    NDVIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for NDVI" | ""
end
#! format: on

function compute(params::vegFraction_scaledNDVI, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_scaledNDVI params

    ## unpack land variables
    @unpack_land begin
        NDVI ∈ land.states
    end

    ## calculate variables
    frac_vegetation = clampZeroOne(NDVI * NDVIscale)

    ## pack land variables
    @pack_land frac_vegetation → land.states
    return land
end

@doc """
sets the value of frac_vegetation by scaling the NDVI value

# Parameters
$(SindbadParameters)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledNDVI

*Inputs*
 - land.states.NDVI : current NDVI value

*Outputs*
 - land.states.frac_vegetation: current vegetation fraction

---

# Extended help

*References*

*Versions*
 - 1.1 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - sbesnard
"""
vegFraction_scaledNDVI
