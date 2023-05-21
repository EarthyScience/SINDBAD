export vegProperties_PFT

@bounds @describe @units @with_kw struct vegProperties_PFT{T1} <: vegProperties
	PFT::T1 = 1.0 | (1.0, 13.0) | "Plant functional type" | "class"
end

function compute(o::vegProperties_PFT, forcing, land, helpers)
	## unpack parameters
	@unpack_vegProperties_PFT o

	## pack land variables
	@pack_land PFT => land.vegProperties
	return land
end

@doc """
sets a uniform PFT class

# Parameters
$(PARAMFIELDS)

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