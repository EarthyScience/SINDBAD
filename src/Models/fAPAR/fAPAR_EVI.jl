export fAPAR_EVI

#! format: off
@bounds @describe @units @timescale @with_kw struct fAPAR_EVI{T1} <: fAPAR
    EVI_to_fAPAR_c::T1 = 0.0 | (-0.2, 0.3) | "intercept of the linear function" | "" | ""
    EVI_to_fAPAR_m::T1 = 1.0 | (0.5, 5) | "slope of the linear function" | "" | ""
end
#! format: on

function compute(params::fAPAR_EVI, forcing, land, helpers)
    @unpack_fAPAR_EVI params

    ## unpack land variables
    @unpack_nt EVI ⇐ land.states

    ## calculate variables
    fAPAR = EVI_to_fAPAR_m * EVI + EVI_to_fAPAR_c
    fAPAR = clampZeroOne(fAPAR)

    ## pack land variables
    @pack_nt fAPAR ⇒ land.states
    return land
end


purpose(::Type{fAPAR_EVI}) = "calculates fAPAR as a linear function of EVI"

@doc """

$(getModelDocString(fAPAR_EVI))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]  

*Created by*
 - skoirala | @dr-ko
"""
fAPAR_EVI
