export cCycle_simple, cCycle_simple_h
"""
Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cCycle_simple{T} <: cCycle
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cCycle_simple, forcing, land, infotem)
	@unpack_cCycle_simple o

	## instantiate variables
	cEcoEfflux = zeros(size(infotem.pools.carbon.initValues.cEco)); #sujan moved from get states
	cEcoOut = ones(size(infotem.pools.carbon.initValues.cEco))
	cEcoFlow = ones(size(infotem.pools.carbon.initValues.cEco))
	cEcoInflux = zeros(size(infotem.pools.carbon.initValues.cEco))
	cEcoFlow = zeros(size(infotem.pools.carbon.initValues.cEco))

	## pack variables
	@pack_land begin
		(cEcoEfflux, cEcoOut, cEcoFlow, cEcoInflux, cEcoFlow) ∋ land.cCycle
	end
	return land
end

function compute(o::cCycle_simple, forcing, land, infotem)
	@unpack_cCycle_simple o

	## unpack variables
	@unpack_land begin
		(cEcoEfflux, cEcoOut, cEcoFlow, cEcoInflux, cEcoFlow) ∈ land.cCycle
		(cAlloc, cEcoEfflux, cEcoFlow, cEcoInflux, cEcoOut, cNPP) ∈ land.states
		(cEco, cEco_prev) ∈ land.pools
		gpp ∈ land.fluxes
		p_k ∈ land.cTau
		(p_A, p_giver, p_taker) ∈ land.cFlow
		(fluxOrder, p_annk) ∈ land.cCycleBase
	end
	TSPY = infotem.dates.nStepsYear; # NUMBER OF TIME STEPS PER YEAR
	p_k = 1 - (exp(-p_annk) ^ (1 / TSPY))
	## these all need to be zeros maybe is taken care automatically.
	## compute losses
	cEcoOut = min(cEco, cEco * p_k)
	## gains to vegetation
	zix = infotem.pools.carbon.flags.cVeg
	cNPP = gpp * cAlloc[zix] - cEcoEfflux[zix]
	cEcoInflux[zix] = cNPP
	# flows & losses
	# @nc; if flux order does not matter; remove# sujanq: this was deleted by simon in the version of 2020-11. Need to
	# find out why. Led to having zeros in most of the carbon pools of the
	# explicit simple
	# old before cleanup was removed during biomascat when cFlowAct was changed to gsi. But original cFlowAct CASA was writing fluxOrder. So; in biomascat; the fields do not exist & this block of code will not work.
	for jix in 1:length(fluxOrder)
		fO = fluxOrder[jix]
		taker = p_taker[fO]
		giver = p_giver[fO]
		cEcoFlow[taker] = cEcoFlow[taker] + cEcoOut[giver] * p_A(taker, giver)
	end
	# for jix = 1:length(p_taker)
	# taker = p_taker[jix]
	# giver = p_giver[jix]
	# c_flow = p_A(taker, giver)
	# take_flow = cEcoFlow[taker]
	# give_flow = cEcoOut[giver]
	# cEcoFlow[taker] = take_flow + give_flow * c_flow
	# end
	## balance
	prevcEco = cEco
	cEco = cEco + cEcoFlow + cEcoInflux - cEcoOut
	## compute RA & RH
	del_cEco = cEco - cEco_prev
	cNPP = sum(cNPP)
	backNEP = sum(cEco) - sum(prevcEco)
	cRA = gpp - cNPP
	cRECO = gpp - backNEP
	cRH = cRECO - cRA
	NEE = cRECO - gpp

	## pack variables
	@pack_land begin
		p_k ∋ land.cCycleBase
		(NEE, cNPP, cRA, cRECO, cRH) ∋ land.fluxes
		(cEcoEfflux, cEcoFlow, cEcoInflux, cEcoOut, cNPP, del_cEco) ∋ land.states
	end
	return land
end

function update(o::cCycle_simple, forcing, land, infotem)
	# @unpack_cCycle_simple o
	return land
end

"""
Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

# precompute:
precompute/instantiate time-invariant variables for cCycle_simple

# compute:
Allocate carbon to vegetation components using cCycle_simple

*Inputs:*
 - infotem.dates.nStepsYear: number of time steps per year
 - land.cCycleBase.p_annk: carbon allocation matrix
 - land.cFlow.p_E: effect of soil & vegetation on transfer efficiency between pools
 - land.cFlow.p_giver: giver pool array
 - land.cFlow.p_taker: taker pool array
 - land.fluxes.gpp: values for gross primary productivity
 - land.states.cAlloc: carbon allocation matrix

*Outputs:*
 - land.cCycleBase.p_k: decay rates for the carbon pool at each time step
 - land.fluxes.cNPP: values for net primary productivity
 - land.fluxes.cRA: values for autotrophic respiration
 - land.fluxes.cRECO: values for ecosystem respiration
 - land.fluxes.cRH: values for heterotrophic respiration
 - land.pools.cEco: values for the different carbon pools
 - land.states.cEcoEfflux:

# update
update pools and states in cCycle_simple
 -

# Extended help

*References:*
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions:*
 - 1.0 on 28.02.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
function cCycle_simple_h end