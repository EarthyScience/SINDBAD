export cFlowSoilProperties_none, cFlowSoilProperties_none_h
"""
set transfer between pools to 0 [i.e. nothing is transfered]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cFlowSoilProperties_none{T} <: cFlowSoilProperties
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cFlowSoilProperties_none, forcing, land, infotem)
	@unpack_cFlowSoilProperties_none o

	## calculate variables
	p_E = repeat(zeros(size(infotem.pools.carbon.initValues.cEco)), 1, 1, infotem.pools.carbon.nZix.cEco)
	p_F = p_E

	## pack variables
	@pack_land begin
		(p_E, p_F) ∋ land.cFlowSoilProperties
	end
	return land
end

function compute(o::cFlowSoilProperties_none, forcing, land, infotem)
	# @unpack_cFlowSoilProperties_none o
	return land
end

function update(o::cFlowSoilProperties_none, forcing, land, infotem)
	# @unpack_cFlowSoilProperties_none o
	return land
end

"""
set transfer between pools to 0 [i.e. nothing is transfered]

# Extended help
"""
function cFlowSoilProperties_none_h end