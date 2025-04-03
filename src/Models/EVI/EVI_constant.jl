export EVI_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct EVI_constant{T1} <: EVI
    constant_EVI::T1 = 1.0 | (0.0, 1.0) | "EVI" | "" | ""
end
#! format: on

function precompute(params::EVI_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_EVI_constant params

    ## calculate variables
    EVI = constant_EVI

    ## pack land variables
    @pack_nt EVI ⇒ land.states
    return land
end

purpose(::Type{EVI_constant}) = "sets the value of EVI as a constant"

@doc """

$(getBaseDocString(EVI_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  

*Created by*
 - skoirala | @dr-ko
"""
EVI_constant
