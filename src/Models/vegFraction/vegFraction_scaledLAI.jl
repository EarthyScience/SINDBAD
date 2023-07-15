export vegFraction_scaledLAI

#! format: off
@bounds @describe @units @with_kw struct vegFraction_scaledLAI{T1} <: vegFraction
    LAIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for LAI" | ""
end
#! format: on

function compute(p_struct::vegFraction_scaledLAI, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_scaledLAI p_struct

    ## unpack land variables
    @unpack_land begin
        LAI ∈ land.states
    end

    ## calculate variables
    frac_vegetation = min_1(LAI * LAIscale)

    ## pack land variables
    @pack_land frac_vegetation => land.states
    return land
end

@doc """
sets the value of frac_vegetation by scaling the LAI value

# Parameters
$(PARAMFIELDS)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledLAI

*Inputs*
 - land.states.LAI : LAI

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
vegFraction_scaledLAI
