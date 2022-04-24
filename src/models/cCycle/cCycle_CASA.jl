export cCycle_CASA, spin_cCycle_CASA

struct cCycle_CASA <: cCycle
end

function precompute(o::cCycle_CASA, forcing, land, helpers)

	## instantiate variables
	cEcoEfflux = zeros(numType, helpers.pools.carbon.nZix.cEco); #sujan moved from get states
	cEcoInflux = zeros(numType, helpers.pools.carbon.nZix.cEco)
	cEcoFlow = zeros(numType, helpers.pools.carbon.nZix.cEco)

	## pack land variables
	@pack_land (cEcoEfflux, cEcoInflux, cEcoFlow) => land.cCycle
	return land
end

function compute(o::cCycle_CASA, forcing, land, helpers)

	## unpack land variables
	@unpack_land (cEcoEfflux, cEcoInflux, cEcoFlow) ∈ land.cCycle

	## unpack land variables
	@unpack_land begin
		(cAlloc, cEcoEfflux, cEcoFlow, cEcoInflux, cEcoOut, cNPP) ∈ land.states
		cEco ∈ land.pools
		gpp ∈ land.fluxes
		p_k ∈ land.cTau
		(p_E, p_F, p_giver, p_taker) ∈ land.cFlow
		(fluxOrder, p_annk) ∈ land.cCycleBase
	end
	# NUMBER OF TIME STEPS PER YEAR
	TSPY = helpers.dates.nStepsYear
	p_k = 1 - (exp(-p_annk) ^ (1 / TSPY))
	## these all need to be zeros maybe is taken care automatically
	cEcoEfflux[!helpers.pools.carbon.flags.cVeg] = 0.0
	## compute losses
	cEcoOut = min(cEco, cEco * p_k)
	## gains to vegetation
	zix = helpers.pools.carbon.flags.cVeg
	cNPP = gpp * cAlloc[zix] - cEcoEfflux[zix]
	cEcoInflux[zix] = cNPP
	## flows & losses
	# @nc; if flux order does not matter; remove.
	for jix in 1:length(fluxOrder)
		taker = p_taker[fluxOrder[jix]]
		giver = p_giver[fluxOrder[jix]]
		flow_tmp = cEcoOut[giver] * p_F(taker, giver)
		cEcoFlow[taker] = cEcoFlow[taker] + flow_tmp * p_E(taker, giver)
		cEcoEfflux[giver] = cEcoEfflux[giver] + flow_tmp * (1.0 - p_E(taker, giver))
	end
	## balance
	cEco = cEco + cEcoFlow + cEcoInflux - cEcoOut
	## compute RA & RH
	cRH = sum(cEcoEfflux[!helpers.pools.carbon.flags.cVeg]); #sujan added 1 to sum along all pools
	cRA = sum(cEcoEfflux[helpers.pools.carbon.flags.cVeg]); #sujan added 1 to sum along all pools
	cRECO = cRH + cRA
	cNPP = sum(cNPP)
	NEE = cRECO - gpp

	## pack land variables
	@pack_land begin
		p_k => land.cCycleBase
		(NEE, cNPP, cRA, cRECO, cRH) => land.fluxes
		(cEcoEfflux, cEcoFlow, cEcoInflux, cEcoOut, cNPP) => land.states
	end
	return land
end

@doc """
Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

---

# compute:
Allocate carbon to vegetation components using cCycle_CASA

*Inputs*
 - helpers.dates.nStepsYear: number of time steps per year
 - land.cCycleBase.p_annk: carbon allocation matrix
 - land.cFlow.p_E: effect of soil & vegetation on transfer efficiency between pools
 - land.cFlow.p_giver: giver pool array
 - land.cFlow.p_taker: taker pool array
 - land.fluxes.gpp: values for gross primary productivity
 - land.states.cAlloc: carbon allocation matrix

*Outputs*
 - land.cCycleBase.p_k: decay rates for the carbon pool at each time step
 - land.fluxes.cNPP: values for net primary productivity
 - land.fluxes.cRA: values for autotrophic respiration
 - land.fluxes.cRECO: values for ecosystem respiration
 - land.fluxes.cRH: values for heterotrophic respiration
 - land.pools.cEco: values for the different carbon pools
 - land.states.cEcoEfflux:
 -

# precompute:
precompute/instantiate time-invariant variables for cCycle_CASA


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 28.02.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cCycle_CASA

"""
Solve the steady state of the cCycle for the CASA model based on recurrent. Returns the model C pools in equilibrium

# Inputs:
 - land.cFlow.p_E: effect of soil & vegetation on transfer efficiency between pools
 - land.cFlow.p_giver: giver pool array
 - land.cFlow.p_taker: taker pool array
 - land.fluxes.gpp: values for gross primary productivity
 - land.history.p_cTau_k: Turn over times carbon pools

# Outputs:
 - land.pools.cEco: states of the different carbon pools

# Modifies:
 -

# Extended help

# References:
 - Not published but similar to: Lardy, R., Bellocchi, G., & Soussana, J. F. (2011). A new method to determine soil organic carbon equilibrium.  Environmental modelling & software, 26[12], 1759-1763.

# Versions:
 - 1.0 on 01.05.2018
 - 1.1 on 29.10.2019: fixed the wrong removal of a dimension by squeeze on  Bt & At when nPix == 1 [single point simulation]

# Created by:
 - ncarval
 - skoirala

# Notes:
 - for model structures that loop the carbon cycle between pools this is  merely a rough approximation [the solution does not really work]  
 - the input datasets [f, fe, fx, s, d] have to have a full year (or cycle  of years) that will be used as the recycling dataset for the  determination of C pools at equilibrium
"""
function spin_cCycle_CASA(forcing, land, helpers, NI2E)
	@unpack_forcing Tair ∈ forcing

	@unpack_land begin
		cEco ∈ land.pools
		(cAlloc, cEco, p_aRespiration_km4su, p_cFlow_A, p_cTau_k) ∈ land.history
		gpp ∈ land.fluxes
		(p_giver, p_taker) ∈ land.cFlow
		YG ∈ land.aRespiration
		(zero, one) ∈ helpers.numbers
	end

	## calculate variables
	# START fCt - final time series of pools
	fCt = cEco
	sCt = cEco
	# updated states / diagnostics & fluxessT = s
	dT = d
	fxT = fx
	# helpers
	nPix = 1
	nTix = info.tem.helpers.sizes.nTix
	nZix = helpers.pools.carbon.nZix.cEco
	# matrices for the calculations
	cLossRate = zeros(nPix, nZix, nTix)
	cGain = cLossRate
	cLoxxRate = cLossRate
	## some debugging
	# if!isfield(land.history, "p_aRespiration_km4su")
	# p_aRespiration_km4su = cLossRate
	# end
	# if!isfield(p, "raAct")
	# p.aRespiration.YG = 1.0
	# elseif!isfield(land.raAct, "YG")
	# p.aRespiration.YG = 1.0
	# end
	## ORDER OF CALCULATIONS [1 to the end of pools]
	zixVec = 1:size(cEco, 2)
	# BUT, we sort from left to right [veg to litter to soil] & prioritize
	# without loops
	kmoves = 0
	zixVecOrder = zixVec
	zixVecOrder_veg = []
	zixVecOrder_nonVeg = []
	for zix in zixVec
		move = false
		ndxGainFrom = find(p_taker == zix)
		ndxLoseToZix = p_taker[p_giver == zix]
		for ii in 1:length(ndxGainFrom)
			giver = p_giver[ndxGainFrom[ii]]
			if any(giver == ndxLoseToZix)
				move = true
				kmoves = kmoves + 1
			end
		end
		if move
			zixVecOrder[zixVecOrder == zix] = []
			zixVecOrder = [zixVecOrder zix]
		end
	end
	for zv in zixVecOrder
		if any(zv == helpers.pools.carbon.zix.cVeg)
			zixVecOrder_veg = [zixVecOrder_veg zv]
		else
			zixVecOrder_nonVeg = [zixVecOrder_nonVeg zv]
		end
	end
	zixVecOrder = [zixVecOrder_veg zixVecOrder_nonVeg]
	# zixVecOrder = [2 1 3 4 5]
	# if kmoves > 0
	# zixVecOrder = [zixVecOrder zixVecOrder[end-kmoves+1:end]]
	# end
	## solve it for each pool individually
	for zix in zixVecOrder
		# general k loss
		# cLossRate[zix, :] = max(min(p_cTau_k[zix, :], one), zero)
		cLossRate[zix, :] = max(min(p_cTau_k[zix, :], 0.9999999), 1e-7); #1 replaced by 0.9999 to avoid having denom in line 140 > 0.
		# so that pools are not NaN
		if any(zix == helpers.pools.carbon.zix.cVeg)
			# additional losses [RA] in veg pools
			cLoxxRate[zix, :] = min(1.0 - p_aRespiration_km4su[zix, :], 1)
			# gains in veg pools
			gppShp = reshape(gpp, nPix, 1, nTix); # could be fxT?
			cGain[zix, :] = cAlloc[zix, :] * gppShp * YG
		end
		if any(zix == p_taker)
			# no additional gains from outside
			if !any(zix == helpers.pools.carbon.zix.cVeg)
				cLoxxRate[zix, :] = 1.0
			end
			# gains from other carbon pools
			ndxGainFrom = find(p_taker == zix)
			for ii in 1:length(ndxGainFrom)
				taker = p_taker[ndxGainFrom[ii]]; # @nc : taker always has to be the same as zix giver = p_giver[ndxGainFrom[ii]]
				denom = (1.0 - cLossRate[giver, :])
				adjustGain = p_cFlow_A[taker, giver, :]
				adjustGain3D = reshape(adjustGain, nPix, 1, nTix)
				cGain[taker, :] = cGain[taker, :] + (fCt[giver, :] / denom) * cLossRate[giver, :] * adjustGain3D
			end
		end
		## GET THE POOLS GAINS [Gt] AND LOSSES [Lt]
		# CALCULATE At = 1 - Lt
		At = squeeze((1.0 - cLossRate[zix, :]) * cLoxxRate[zix, :])
		#sujan 29.10.2019: the squeeze removes the first dimension while
		#running for a single point when nPix == 1
		if size(cLossRate, 1) == 1
			# At = At"; # commented out for julia compilation. make sure it works.
			# Bt = squeeze(cGain[zix, :])" * At; # commented out for julia compilation. make sure it works.
		else
			Bt = squeeze(cGain[zix, :]) * At
		end
		#sujan end squeeze fix
		# CARBON AT THE END FOR THE FIRST SPINUP PHASE; NPP IN EQUILIBRIUM
		Co = cEco[zix]
		# THE NEXT LINES REPRESENT THE ANALYTICAL SOLUTION FOR THE SPIN UP
		# EXCEPT FOR THE LAST 3 POOLS: SOIL MICROBIAL; SLOW AND OLD. IN THIS
		# CASE SIGNIFICANT APPROXIMATION IS CALCULATED [CHECK NOTEBOOKS].
		piA1 = (prod(At, 2)) ^ (NI2E)
		At2 = [At ones(size(At, 1), 1)]
		sumB_piA = NaN(size(Tair))
		for ii in 1:nTix
			sumB_piA[ii] = Bt[ii] * prod(At2[ii + 1:nTix + 1], 2)
		end
		sumB_piA = sum(sumB_piA)
		T2 = 0:1:NI2E - 1
		piA2 = (prod(At, 2) * ones(1, length(T2))) ^ (ones(size(At, 1), 1) * T2)
		piA2 = sum(piA2)
		# FINAL CARBON AT POOL zix
		Ct = Co * piA1 + sumB_piA * piA2
		sCt[zix] = Ct
		cEco[zix] = Ct
		cEco_prev[zix] = Ct
		# CREATE A YEARLY TIME SERIES OF THE POOLS EXCHANGE TO USE IN THE NEXT
		# POOLS CALCULATIONS
		out = runForward(selectedModels, forcing, out, modelnames, helpers)
		# FEED fCt
		# fCt[zix, :] = cEco[zix, :]
		fCt = cEco
	end
	# make the fx consistent with the pools
	cEco = sCt
	cEco_prev = sCt
	out = runForward(selectedModels, forcing, out, modelnames, helpers)

	## pack land variables
	@pack_land (cEco, cEco_prev) => land.pools
	return land
end

