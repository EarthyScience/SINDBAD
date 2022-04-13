export cFlow_none, cFlow_none_h
"""
set transfer between pools to 0 [i.e. nothing is transfered] set giver & taker matrices to [] get the transfer matrix transfers

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cFlow_none{T} <: cFlow
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cFlow_none, forcing, land, infotem)
	@unpack_cFlow_none o

	## calculate variables
	tmp = repeat(zeros(size(infotem.pools.carbon.initValues.cEco)), 1, 1, infotem.pools.carbon.nZix.cEco)
	p_A = tmp
	p_E = tmp
	p_F = tmp
	p_taker = []
	p_giver = []

	## pack variables
	@pack_land begin
		(p_A, p_E, p_F, p_giver, p_taker) ∋ land.cFlow
	end
	return land
end

function compute(o::cFlow_none, forcing, land, infotem)
	# @unpack_cFlow_none o
	return land
end

function update(o::cFlow_none, forcing, land, infotem)
	# @unpack_cFlow_none o
	return land
end

"""
set transfer between pools to 0 [i.e. nothing is transfered] set giver & taker matrices to [] get the transfer matrix transfers

# Extended help
"""
function cFlow_none_h end