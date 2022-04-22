export cFlow_CASA

struct cFlow_CASA <: cFlow
end

function compute(o::cFlow_CASA, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		(p_E, p_F) ∈ land.cFlowVegProperties
		(p_E, p_F) ∈ land.cFlowSoilProperties
		cFlowE ∈ land.cCycleBase
		(zero, one) ∈ helpers.numbers
	end
	#@nc : this needs to go in the full.
	# effects of soil & veg on the [microbial] efficiency of c flows between carbon pools
	tmp = repeat(reshape(cFlowE, [1 size(cFlowE)]), 1, 1)
	p_E = tmp + p_E + p_E
	# effects of soil & veg on the partitioning of c flows between carbon pools
	p_F = p_F + p_F
	# if there is fraction [F] & efficiency is 0, make efficiency 1
	ndx = p_F > zero & p_E == zero
	p_E[ndx] = one
	# if there is not fraction, but efficiency exists, make fraction == 1 [should give an error if there are more than 1 flux out of this pool]
	ndx = p_E > zero & p_F == zero
	p_F[ndx] = one
	# build A
	p_A = p_F * p_E
	# transfers
	(taker, giver) = find(squeeze(sum(p_A > zero)) >= one)
	p_taker = taker
	p_giver = giver
	# if there is flux order check that is consistent
	if !isfield(land.cCycleBase, :fluxOrder)
		fluxOrder = 1:length(taker)
	else
		if length(fluxOrder) != length(taker)
			error(["ERR : cFlowAct_CASA : " "length(fluxOrder) != length(taker)"])
		end
	end

	## pack land variables
	@pack_land begin
		fluxOrder => land.cCycleBase
		(p_A, p_E, p_F, p_giver, p_taker) => land.cFlow
	end
	return land
end

@doc """
combine all the effects that change the transfers between carbon pools

---

# compute:
Actual transfers of c between pools (of diagonal components) using cFlow_CASA

*Inputs*
 - land.cCycleBase.cFlowE: transfer matrix for carbon at ecosystem level
 - land.cFlowSoilProperties.p_E: effect of soil on transfer efficiency between pools
 - land.cFlowSoilProperties.p_F: effect of vegetation on transfer fraction between pools
 - land.cFlowVegProperties.p_E: effect of soil on transfer efficiency between pools
 - land.cFlowVegProperties.p_F effect of vegetation on transfer fraction between pools

*Outputs*
 - land.cFlow.p_A: effect of soil & vegetation on actual transfer rates between pools
 - land.cFlow.p_E: effect of soil & vegetation on transfer efficiency between pools
 - land.cFlow.p_F: effect of soil & vegetation on transfer fraction between pools
 - land.cFlow.p_A
 - land.cFlow.p_E
 - land.cFlow.p_F

---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 13.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cFlow_CASA