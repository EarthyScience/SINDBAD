export cFlow_simple

struct cFlow_simple <: cFlow
end

function compute(o::cFlow_simple, forcing, land, helpers)

	## unpack land variables
	@unpack_land cFlowA ∈ land.cCycleBase


	## calculate variables
	#@nc : this needs to go in the full..
	# Do A matrix..
	p_A = repeat(reshape(cFlowA, [1 size(cFlowA)]), 1, 1)
	# transfers
	(taker, giver) = find(squeeze(sum(p_A > 0.0)) >= 1)
	p_taker = taker
	p_giver = giver
	# if there is flux order check that is consistent
	if !isfield(land.cCycleBase, :flowOrder)
		flowOrder = 1:length(taker)
	else
		if length(flowOrder) != length(taker)
			error(["ERR : cFlowAct_simple : " "length(flowOrder) != length(taker)"])
		end
	end

	## pack land variables
	@pack_land begin
		flowOrder => land.cCycleBase
		(p_A, p_giver, p_taker) => land.cFlow
	end
	return land
end

@doc """
combine all the effects that change the transfers between carbon pools

---

# compute:
Actual transfers of c between pools (of diagonal components) using cFlow_simple

*Inputs*
 - land.cCycleBase.cFlowA: transfer matrix for carbon at ecosystem level

*Outputs*
 - land.cFlow.p_A: effect of vegetation & vegetation on actual transfer rates between pools
 - land.cFlow.p_A

---

# Extended help

*References*

*Versions*
 - 1.0 on 13.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cFlow_simple