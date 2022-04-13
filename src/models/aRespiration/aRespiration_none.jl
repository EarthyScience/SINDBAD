export aRespiration_none, aRespiration_none_h
"""
sets the outflow from all vegetation pools to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct aRespiration_none{T} <: aRespiration
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::aRespiration_none, forcing, land, infotem)
	@unpack_aRespiration_none o

	## calculate variables
	zix = infotem.pools.carbon.zix.cVeg
	cEcoEfflux[zix] = 0.0

	## pack variables
	@pack_land begin
		cEcoEfflux ∋ land.states
	end
	return land
end

function compute(o::aRespiration_none, forcing, land, infotem)
	# @unpack_aRespiration_none o
	return land
end

function update(o::aRespiration_none, forcing, land, infotem)
	# @unpack_aRespiration_none o
	return land
end

"""
sets the outflow from all vegetation pools to zeros

# Extended help
"""
function aRespiration_none_h end