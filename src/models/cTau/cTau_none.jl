export cTau_none, cTau_none_h
"""
set the actual τ to ones

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTau_none{T} <: cTau
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cTau_none, forcing, land, infotem)
	@unpack_cTau_none o

	## calculate variables
	p_k = ones(size(infotem.pools.carbon.initValues.cEco))

	## pack variables
	@pack_land begin
		p_k ∋ land.cTau
	end
	return land
end

function compute(o::cTau_none, forcing, land, infotem)
	# @unpack_cTau_none o
	return land
end

function update(o::cTau_none, forcing, land, infotem)
	# @unpack_cTau_none o
	return land
end

"""
set the actual τ to ones

# Extended help
"""
function cTau_none_h end