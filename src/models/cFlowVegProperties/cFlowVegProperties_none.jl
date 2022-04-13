export cFlowVegProperties_none, cFlowVegProperties_none_h
"""
set transfer between pools to 0 [i.e. nothing is transfered]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cFlowVegProperties_none{T} <: cFlowVegProperties
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cFlowVegProperties_none, forcing, land, infotem)
	@unpack_cFlowVegProperties_none o

	## calculate variables
	p_F = repeat(zeros(size(infotem.pools.carbon.initValues.cEco)), 1, 1, infotem.pools.carbon.nZix.cEco)
	p_E = p_F

	## pack variables
	@pack_land begin
		(p_E, p_F) ∋ land.cFlowVegProperties
	end
	return land
end

function compute(o::cFlowVegProperties_none, forcing, land, infotem)
	# @unpack_cFlowVegProperties_none o
	return land
end

function update(o::cFlowVegProperties_none, forcing, land, infotem)
	# @unpack_cFlowVegProperties_none o
	return land
end

"""
set transfer between pools to 0 [i.e. nothing is transfered]

# Extended help
"""
function cFlowVegProperties_none_h end