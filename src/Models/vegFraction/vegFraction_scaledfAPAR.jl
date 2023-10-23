export vegFraction_scaledfAPAR

#! format: off
@bounds @describe @units @with_kw struct vegFraction_scaledfAPAR{T1} <: vegFraction
    fAPAR_scalar::T1 = 10.0 | (0.0, 20.0) | "scalar for fAPAR" | ""
end
#! format: on

function compute(params::vegFraction_scaledfAPAR, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_scaledfAPAR params

    ## unpack land variables
    @unpack_nt begin
        fAPAR ⇐ land.states
    end

    ## calculate variables
    frac_vegetation = minOne(fAPAR * fAPAR_scalar)

    ## pack land variables
    @pack_nt frac_vegetation ⇒ land.states
    return land
end

@doc """
sets the value of frac_vegetation by scaling the fAPAR value

# Parameters
$(SindbadParameters)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledfAPAR

*Inputs*
 - land.states.fAPAR : fAPAR value

*Outputs*
 - land.states.frac_vegetation: current vegetation fraction

---

# Extended help

*References*

*Versions*
 - 1.1 on 24.10.2020 [ttraut]: new module  

*Created by:*
 - sbesnard
"""
vegFraction_scaledfAPAR
