export fAPAR_vegFraction

#! format: off
@bounds @describe @units @timescale @with_kw struct fAPAR_vegFraction{T1} <: fAPAR
    frac_vegetation_to_fAPAR::T1 = 0.989 | (0.00001, 0.99) | "linear fraction of fAPAR and frac_vegetation" | "" | ""
end
#! format: on

function compute(params::fAPAR_vegFraction, forcing, land, helpers)
    @unpack_fAPAR_vegFraction params

    ## unpack land variables
    @unpack_nt frac_vegetation ⇐ land.states

    ## calculate variables
    fAPAR = frac_vegetation_to_fAPAR * frac_vegetation

    ## pack land variables
    @pack_nt fAPAR ⇒ land.states
    return land
end

purpose(::Type{fAPAR_vegFraction}) = "fAPAR as a linear function of vegetation fraction."

@doc """

$(getModelDocString(fAPAR_vegFraction))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]  

*Created by*
 - skoirala | @dr-ko
"""
fAPAR_vegFraction
