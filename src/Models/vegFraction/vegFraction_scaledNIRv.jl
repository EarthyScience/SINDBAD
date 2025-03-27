export vegFraction_scaledNIRv

#! format: off
@bounds @describe @units @timescale @with_kw struct vegFraction_scaledNIRv{T1} <: vegFraction
    NIRvscale::T1 = 1.0 | (0.0, 5.0) | "scalar for NIRv" | "" | ""
end
#! format: on

function compute(params::vegFraction_scaledNIRv, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_scaledNIRv params

    ## unpack land variables
    @unpack_nt begin
        NIRv ⇐ land.states
    end

    ## calculate variables
    frac_vegetation = clampZeroOne(NIRv * NIRvscale)

    ## pack land variables
    @pack_nt frac_vegetation ⇒ land.states
    return land
end

@doc """
sets the value of frac_vegetation by scaling the NIRv value

# Parameters
$(SindbadParameters)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledNIRv

*Inputs*
 - land.states.NIRv : current NIRv value

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
vegFraction_scaledNIRv
