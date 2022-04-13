export cTauLAI_none, cTauLAI_none_h
"""
set values to ones

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTauLAI_none{T} <: cTauLAI
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cTauLAI_none, forcing, land, infotem)
	@unpack_cTauLAI_none o

	## calculate variables
	p_kfLAI = ones(size(infotem.pools.carbon.initValues.cEco)); #(ineficient, should be pix zix_veg)

	## pack variables
	@pack_land begin
		p_kfLAI ∋ land.cTauLAI
	end
	return land
end

function compute(o::cTauLAI_none, forcing, land, infotem)
	# @unpack_cTauLAI_none o
	return land
end

function update(o::cTauLAI_none, forcing, land, infotem)
	# @unpack_cTauLAI_none o
	return land
end

"""
set values to ones

# Extended help
"""
function cTauLAI_none_h end