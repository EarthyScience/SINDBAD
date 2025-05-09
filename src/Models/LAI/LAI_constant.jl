export LAI_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct LAI_constant{T1} <: LAI
    constant_LAI::T1 = 3.0 | (1.0, 12.0) | "LAI" | "m2/m2" | ""
end
#! format: on

function precompute(params::LAI_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_LAI_constant params

    ## calculate variables
    LAI = constant_LAI

    ## pack land variables
    @pack_nt LAI ⇒ land.states
    return land
end

purpose(::Type{LAI_constant}) = "sets the value of LAI as a constant"

@doc """

$(getModelDocString(LAI_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  

*Created by*
 - skoirala | @dr-ko
"""
LAI_constant
