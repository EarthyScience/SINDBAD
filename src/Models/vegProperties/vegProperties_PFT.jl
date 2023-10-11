export vegProperties_PFT

#! format: off
@bounds @describe @units @with_kw struct vegProperties_PFT{T1} <: vegProperties
    PFT::T1 = 1.0 | (1.0, 13.0) | "Plant functional type" | "class"
end
#! format: on

function compute(params::vegProperties_PFT, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegProperties_PFT params

    ## pack land variables
    @pack_land PFT => land.vegProperties
    return land
end

@doc """
sets a uniform PFT class

# Parameters
$(SindbadParameters)

---

# compute:
Vegetation/structural properties using vegProperties_PFT

*Inputs*
 -
 - info structure

*Outputs*

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - unknown [xxx]
"""
vegProperties_PFT
