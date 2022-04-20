export aRespiration_Thornley2000C

@bounds @describe @units @with_kw struct aRespiration_Thornley2000C{T1, T2} <: aRespiration
	RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/day"
	YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC"
end

function compute(o::aRespiration_Thornley2000C, forcing, land, helpers)
	## unpack parameters
	@unpack_aRespiration_Thornley2000C o

	## unpack land variables
	@unpack_land begin
		(RA_G, RA_M, cAlloc) ∈ land.states
		cEco ∈ land.pools
		gpp ∈ land.fluxes
		MTF ∈ land.cTauVegProperties
		p_C2Nveg ∈ land.cCycleBase
		fT ∈ land.aRespirationAirT
	end
	p_km = repeat([1.0] , 1, helpers.pools.carbon.nZix.cVeg)
	p_km4su = p_km
	RA_G = p_km
	RA_M = p_km
	# adjust nitrogen efficiency rate of maintenance respiration
	RMN = RMN / helpers.dates.nStepsDay
	for zix in helpers.pools.carbon.zix.cVeg
		# make the Fd of each pool equal to the MTF
		if flagMTF
			Fd[zix] = MTF
		else
			Fd[zix] = 1.0
		end
		# scalars of maintenance respiration for models A; B & C
		# km is the maintenance respiration coefficient [d-1]
		km = 1 / p_C2Nveg[zix] * RMN * fT
		kd = Fd[zix]
		p_km[zix] = km * kd
		p_km4su[zix] = p_km[zix] * (1.0 - YG)
		# compute maintenance & growth respiration terms for each vegetation pool
		# according to MODEL C - growth; degradation & resynthesis view of
		# respiration
		# maintenance respiration: R_m = km * (1.0 - YG) * C; km = km * MTF [before equivalent to kd]
		RA_M[zix] = p_km[zix] * (1.0 - YG) * cEco[zix]
		# growth respiration: R_g = gpp * (1.0 - YG)
		RA_G[zix] = (1.0 - YG) * gpp * cAlloc[zix]
		# total respiration per pool: R_a = R_m + R_g
		cEcoEfflux[zix] = RA_M[zix] + RA_G[zix]
	end

	## pack land variables
	@pack_land begin
		(p_km, p_km4su) => land.aRespiration
		(RA_G, RA_M, cEcoEfflux) => land.states
	end
	return land
end

@doc """
Precomputations to estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell (2000): MODEL C - growth, degradation & resynthesis view of respiration (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient]

# Parameters
$(PARAMFIELDS)

---

# compute:
Determine growth and maintenance respiration -> npp using aRespiration_Thornley2000C

*Inputs*
 - info.timeScale.stepsPerDay: number of time steps per day
 - land.aRespirationAirT.fT: temperature effect on autrotrophic respiration [δT-1]
 - land.cCycle.MTF: metabolic fraction [[]]
 - land.cCycleBase.C2Nveg[zix]: carbon to nitrogen ratio [gC.gN-1]

*Outputs*
 - land.aRespiration.km[ii].value: maintenance [respiration] coefficient - dependent on  temperature and; depending on the models; degradable fraction  (δT-1)
 -

---

# Extended help

*References*
 - Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.  Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
 - Thornley, J. H. M., & M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation & realism, Ann Bot-London, 85[1]  55-67.

*Versions*
 - 1.0 on 06.02.2020 [sbesnard]: cleaned up the code  

*Created by:*
 - ncarval

*Notes*
 - Another thing to consider is if this a double count; since we have C2N  ratios?
 - Fd is the decomposable fraction from each plant pool [see Thornley and Cannell 2000]. Since we dont discriminate in the model, this should be based on literature values [e.g. sap to hard wood ratios]. Before this fraction was made equivalent to the metabolic fraction in residues -strong assumption. Until somebody looks at this, we keep the same approach & add a flag to model parameters to switch it off.
"""
aRespiration_Thornley2000C