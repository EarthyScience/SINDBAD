export vegFraction_scaledEVI

#! format: off
@bounds @describe @units @with_kw struct vegFraction_scaledEVI{T1} <: vegFraction
    EVIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for EVI" | ""
end
#! format: on

function compute(p_struct::vegFraction_scaledEVI, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_scaledEVI p_struct

    ## unpack land variables
    @unpack_land begin
        EVI ∈ land.states
    end

    ## calculate variables
    frac_vegetation = minOne(EVI * EVIscale)

    ## pack land variables
    @pack_land frac_vegetation => land.states
    return land
end

@doc """
sets the value of frac_vegetation by scaling the EVI value

# Parameters
$(SindbadParameters)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledEVI

*Inputs*
 - land.states.EVI : current EVI value

*Outputs*
 - land.states.frac_vegetation: current vegetation fraction

---

# Extended help

*References*

*Versions*
 - 1.0 on 06.02.2020 [ttraut]  
 - 1.1 on 05.03.2020 [ttraut]: apply the min function

*Created by:*
 - ttraut
"""
vegFraction_scaledEVI
