export fAPAR_vegFraction

#! format: off
@bounds @describe @units @with_kw struct fAPAR_vegFraction{T1} <: fAPAR
    frac_vegetation_to_fAPAR::T1 = 0.989 | (0.00001, 0.99) | "linear fraction of fAPAR and frac_vegetation" | ""
end
#! format: on

function compute(params::fAPAR_vegFraction, forcing, land, helpers)
    @unpack_fAPAR_vegFraction params

    ## unpack land variables
    @unpack_land frac_vegetation ∈ land.states

    ## calculate variables
    fAPAR = frac_vegetation_to_fAPAR * frac_vegetation

    ## pack land variables
    @pack_land fAPAR => land.states
    return land
end

@doc """
sets the value of fAPAR as a linear function of vegetation fraction

# Parameters
$(SindbadParameters)

---

# compute:
Fraction of absorbed photosynthetically active radiation from frac_vegetation

*Inputs*
 - land.states.frac_vegetation: vegetated fraction, which needs frac_vegetation module to be activated

*Outputs*
 - land.states.fAPAR: fAPAR as a fraction of vegetation fraction

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]  

*Created by:*
 - skoirala
"""
fAPAR_vegFraction
