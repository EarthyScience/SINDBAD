export treeFraction_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct treeFraction_constant{T1} <: treeFraction
    constant_frac_tree::T1 = 1.0 | (0.3, 1.0) | "Tree fraction" | "" | ""
end
#! format: on


function precompute(params::treeFraction_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_treeFraction_constant params

    ## calculate variables
    frac_tree = constant_frac_tree

    ## pack land variables
    @pack_nt frac_tree ⇒ land.states
    return land
end

purpose(::Type{treeFraction_constant}) = "sets frac_tree as a constant"

@doc """

$(getModelDocString(treeFraction_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  

*Created by*
 - skoirala | @dr-ko
"""
treeFraction_constant
