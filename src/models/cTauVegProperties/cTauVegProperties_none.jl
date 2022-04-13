export cTauVegProperties_none, cTauVegProperties_none_h
"""
set the outputs to ones

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTauVegProperties_none{T} <: cTauVegProperties
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cTauVegProperties_none, forcing, land, infotem)
	@unpack_cTauVegProperties_none o

	## calculate variables
	p_kfVeg = ones(size(infotem.pools.carbon.initValues.cEco))
	p_LITC2N = 0.0
	p_LIGNIN = 0.0
	p_MTF = 1.0
	p_SCLIGNIN = 0.0
	p_LIGEFF = 0.0

	## pack variables
	@pack_land begin
		(p_LIGEFF, p_LIGNIN, p_LITC2N, p_MTF, p_SCLIGNIN, p_kfVeg) ∋ land.cTauVegProperties
	end
	return land
end

function compute(o::cTauVegProperties_none, forcing, land, infotem)
	# @unpack_cTauVegProperties_none o
	return land
end

function update(o::cTauVegProperties_none, forcing, land, infotem)
	# @unpack_cTauVegProperties_none o
	return land
end

"""
set the outputs to ones

# Extended help
"""
function cTauVegProperties_none_h end