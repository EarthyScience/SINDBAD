export fAPAR_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct fAPAR_constant{T1} <: fAPAR
    constant_fAPAR::T1 = 0.2 | (0.0, 1.0) | "a constant fAPAR" | "" | ""
end
#! format: on

function precompute(params::fAPAR_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_fAPAR_constant params

    ## calculate variables
    fAPAR = constant_fAPAR

    ## pack land variables
    @pack_nt fAPAR ⇒ land.states
    return land
end

purpose(::Type{fAPAR_constant}) = "Sets fAPAR as a constant value."

@doc """

$(getModelDocString(fAPAR_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  

*Created by*
 - skoirala | @dr-ko
"""
fAPAR_constant
