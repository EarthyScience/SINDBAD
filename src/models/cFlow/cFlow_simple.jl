export cFlow_simple, cFlow_simple_h
"""
combine all the effects that change the transfers between carbon pools

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cFlow_simple{T} <: cFlow
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cFlow_simple, forcing, land, infotem)
	# @unpack_cFlow_simple o
	return land
end

function compute(o::cFlow_simple, forcing, land, infotem)
	@unpack_cFlow_simple o

	## unpack variables
	@unpack_land begin
		cFlowA ∈ land.cCycleBase
	end
	#@nc : this needs to go in the full..
	# Do A matrix..
	p_A = repeat(reshape(cFlowA, [1 size(cFlowA)]), 1, 1)
	# transfers
	(taker, giver) = find(squeeze(sum(p_A > 0.0)) >= 1)
	p_taker = taker
	p_giver = giver
	# if there is flux order check that is consistent
	if !isfield(land.cCycleBase, :fluxOrder)
		fluxOrder = 1:length(taker)
	else
		if length(fluxOrder) != length(taker)
			error(["ERR : cFlowAct_simple : " "length(fluxOrder) != length(taker)"])
		end
	end

	## pack variables
	@pack_land begin
		fluxOrder ∋ land.cCycleBase
		(p_A, p_giver, p_taker) ∋ land.cFlow
	end
	return land
end

function update(o::cFlow_simple, forcing, land, infotem)
	# @unpack_cFlow_simple o
	return land
end

"""
combine all the effects that change the transfers between carbon pools

# precompute:
precompute/instantiate time-invariant variables for cFlow_simple

# compute:
Actual transfers of c between pools (of diagonal components) using cFlow_simple

*Inputs:*
 - land.cCycleBase.cFlowA: transfer matrix for carbon at ecosystem level

*Outputs:*
 - land.cFlow.p_A: effect of vegetation & vegetation on actual transfer rates between pools

# update
update pools and states in cFlow_simple
 - land.cFlow.p_A

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 13.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
function cFlow_simple_h end