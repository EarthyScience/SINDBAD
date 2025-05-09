export NIRv_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct NIRv_constant{T1} <: NIRv
    constant_NIRv::T1 = 1.0 | (0.0, 1.0) | "NIRv" | "" | ""
end
#! format: on

function precompute(params::NIRv_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_NIRv_constant params

    ## calculate variables
    NIRv = constant_NIRv

    ## pack land variables
    @pack_nt NIRv ⇒ land.states
    return land
end

purpose(::Type{NIRv_constant}) = "sets NIRv as a constant"

@doc """

$(getModelDocString(NIRv_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by*
 - sbesnard
"""
NIRv_constant
