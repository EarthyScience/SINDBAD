export cTauSoilProperties_none, cTauSoilProperties_none_h
"""
Set soil texture effects to ones (ineficient, should be pix zix_mic)

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTauSoilProperties_none{T} <: cTauSoilProperties
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cTauSoilProperties_none, forcing, land, infotem)
	@unpack_cTauSoilProperties_none o

	## calculate variables
	p_kfSoil = ones(size(infotem.pools.carbon.initValues.cEco))

	## pack variables
	@pack_land begin
		p_kfSoil ∋ land.cTauSoilProperties
	end
	return land
end

function compute(o::cTauSoilProperties_none, forcing, land, infotem)
	# @unpack_cTauSoilProperties_none o
	return land
end

function update(o::cTauSoilProperties_none, forcing, land, infotem)
	# @unpack_cTauSoilProperties_none o
	return land
end

"""
Set soil texture effects to ones (ineficient, should be pix zix_mic)

# Extended help
"""
function cTauSoilProperties_none_h end