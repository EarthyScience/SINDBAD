export PFT_constant

#! format: off
@bounds @describe @units @with_kw struct PFT_constant{T1} <: PFT
    PFT::T1 = 1.0 | (1.0, 13.0) | "Plant functional type" | "class"
end
#! format: on

function precompute(params::PFT_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_PFT_constant params

    ## pack land variables
    @pack_nt PFT ⇒ land.PFT
    return land
end

@doc """
sets a uniform PFT class

# Parameters
$(SindbadParameters)

---

# compute:
Vegetation PFT using PFT_constant

*Inputs*
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
PFT_constant
