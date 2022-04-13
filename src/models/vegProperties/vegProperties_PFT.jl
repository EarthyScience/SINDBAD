export vegProperties_PFT, vegProperties_PFT_h
"""
sets a uniform PFT class. all calculations are done in prec

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegProperties_PFT{T1} <: vegProperties
	PFT::T1 = 1.0 | (1.0, 13.0) | "Plant functional type" | "class"
end

function precompute(o::vegProperties_PFT, forcing, land, infotem)
	# @unpack_vegProperties_PFT o
	return land
end

function compute(o::vegProperties_PFT, forcing, land, infotem)
	@unpack_vegProperties_PFT o

	## unpack variables

	## calculate variables

	## pack variables
	return land
end

function update(o::vegProperties_PFT, forcing, land, infotem)
	# @unpack_vegProperties_PFT o
	return land
end

"""
sets a uniform PFT class. all calculations are done in prec

# precompute:
precompute/instantiate time-invariant variables for vegProperties_PFT

# compute:
Vegetation/structural properties using vegProperties_PFT

*Inputs:*
 -
 - info structure

*Outputs:*

# update
update pools and states in vegProperties_PFT

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - unknown [xxx]
"""
function vegProperties_PFT_h end