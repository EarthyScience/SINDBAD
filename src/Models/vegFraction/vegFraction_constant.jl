export vegFraction_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct vegFraction_constant{T1} <: vegFraction
    constant_frac_vegetation::T1 = 0.5 | (0.3, 0.9) | "Vegetation fraction" | "" | ""
end
#! format: on

function precompute(params::vegFraction_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_constant params

    ## calculate variables
    frac_vegetation = constant_frac_vegetation

    ## pack land variables
    @pack_nt frac_vegetation ⇒ land.states
    return land
end

purpose(::Type{vegFraction_constant}) = "sets the value of frac_vegetation as a constant"

@doc """

$(getBaseDocString(vegFraction_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  

*Created by*
 - skoirala | @dr-ko
"""
vegFraction_constant
