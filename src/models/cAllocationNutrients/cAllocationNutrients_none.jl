export cAllocationNutrients_none, cAllocationNutrients_none_h
"""
set the pseudo-nutrient limitation to 1

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationNutrients_none{T} <: cAllocationNutrients
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocationNutrients_none, forcing, land, infotem)
	@unpack_cAllocationNutrients_none o

	## calculate variables
	minWLNL = 1.0

	## pack variables
	@pack_land begin
		minWLNL ∋ land.cAllocationNutrients
	end
	return land
end

function compute(o::cAllocationNutrients_none, forcing, land, infotem)
	# @unpack_cAllocationNutrients_none o
	return land
end

function update(o::cAllocationNutrients_none, forcing, land, infotem)
	# @unpack_cAllocationNutrients_none o
	return land
end

"""
set the pseudo-nutrient limitation to 1

# Extended help
"""
function cAllocationNutrients_none_h end