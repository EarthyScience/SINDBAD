export aRespiration_Thornley2000B

@bounds @describe @units @with_kw struct aRespiration_Thornley2000B{T1, T2} <: aRespiration
	RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/day"
	YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC"
end

function compute(o::aRespiration_Thornley2000B, forcing, land, helpers)
	## unpack parameters
	@unpack_aRespiration_Thornley2000B o

	## unpack land variables
	@unpack_land begin
		(RA_G, RA_M, cAlloc) ∈ land.states
		cEco ∈ land.pools
		gpp ∈ land.fluxes
		p_C2Nveg ∈ land.cCycleBase
		fT ∈ land.aRespirationAirT
		km ∈ land.aRespiration
	end
	p_km = repeat([1.0] , 1, length(land.pools.cVeg))
	p_km4su = p_km
	RA_G = p_km
	RA_M = p_km
	# adjust nitrogen efficiency rate of maintenance respiration
	RMN = RMN / helpers.dates.nStepsDay
	# compute maintenance & growth respiration terms for each vegetation pool
	# according to MODEL B - growth respiration is given priority
	for zix in helpers.pools.carbon.cVeg.zix
		# scalars of maintenance respiration for models A; B & C
		# km is the maintenance respiration coefficient [d-1]
		p_km[zix] = 1 / p_C2Nveg[zix] * RMN * fT
		p_km4su[zix] = p_km[zix]
		# growth respiration: R_g = (1.0 - YG) * GPP * allocationToPool
		RA_G[zix] = (1.0 - YG) * gpp * cAlloc[zix]
		# maintenance respiration: R_m = km * (C + YG * GPP * allocationToPool)
		RA_M[zix] = km[zix].value * (cEco[zix] + YG * gpp * cAlloc[zix])
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
Precomputations to estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell (2000): MODEL B - growth respiration is given priority (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient]

# Parameters
$(PARAMFIELDS)

---

# compute:
Determine growth and maintenance respiration -> npp using aRespiration_Thornley2000B

*Inputs*
 - info.timeScale.stepsPerDay: number of time steps per day
 - land.aRespirationAirT.fT: temperature effect on autrotrophic respiration [δT-1]
 - land.cCycle.MTF: metabolic fraction [[]]
 - land.cCycleBase.C2Nveg[zix]: carbon to nitrogen ratio [gC.gN-1]

*Outputs*
 - land.aRespiration.km[ii].value: maintenance [respiration] coefficient - dependent on  temperature and; depending on the models; degradable fraction  (δT-1)

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
 -  
"""
aRespiration_Thornley2000B