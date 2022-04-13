export cTauSoilW_none, cTauSoilW_none_h
"""
set the moisture stress for all carbon pools to ones

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTauSoilW_none{T} <: cTauSoilW
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cTauSoilW_none, forcing, land, infotem)
	@unpack_cTauSoilW_none o

	## calculate variables
	p_fsoilW = ones(size(infotem.pools.carbon.initValues.cEco))

	## pack variables
	@pack_land begin
		p_fsoilW ∋ land.cTauSoilW
	end
	return land
end

function compute(o::cTauSoilW_none, forcing, land, infotem)
	# @unpack_cTauSoilW_none o
	return land
end

function update(o::cTauSoilW_none, forcing, land, infotem)
	# @unpack_cTauSoilW_none o
	return land
end

"""
set the moisture stress for all carbon pools to ones

# Extended help
"""
function cTauSoilW_none_h end