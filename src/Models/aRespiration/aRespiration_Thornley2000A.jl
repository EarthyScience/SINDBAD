export aRespiration_Thornley2000A

@bounds @describe @units @with_kw struct aRespiration_Thornley2000A{T1, T2} <: aRespiration
	RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/day"
	YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC"
end

function precompute(o::aRespiration_Thornley2000A, forcing, land, helpers)
	@unpack_land begin
		cEco ∈ land.pools
		numType ∈ helpers.numbers
	end
	
	p_km = zero(land.pools.cEco) .+ helpers.numbers.𝟙
	p_km4su = zero(land.pools.cEco) .+ helpers.numbers.𝟙
	RA_G = zero(land.pools.cEco)
	RA_M = zero(land.pools.cEco)

	## pack land variables
	@pack_land begin
		(p_km, p_km4su) => land.aRespiration
		(RA_G, RA_M) => land.states
	end
	return land
end

function compute(o::aRespiration_Thornley2000A, forcing, land, helpers)
	## unpack parameters
	@unpack_aRespiration_Thornley2000A o

	## unpack land variables
	@unpack_land begin
		(p_km, p_km4su) ∈ land.aRespiration
		(cAlloc, cEcoEfflux, RA_G, RA_M) ∈ land.states
		cEco ∈ land.pools
		gpp ∈ land.fluxes
		p_C2Nveg ∈ land.cCycleBase
		fT ∈ land.aRespirationAirT
		(𝟙, 𝟘, numType) ∈ helpers.numbers
	end
	# adjust nitrogen efficiency rate of maintenance respiration to the current
	# model time step
	RMN = RMN / helpers.dates.nStepsDay
    zix = getzix(getfield(land.pools, :cVeg), helpers.pools.carbon.zix.cVeg)
    for ix in zix

		# compute maintenance & growth respiration terms for each vegetation pool
		# according to MODEL A - maintenance respiration is given priority

		# scalars of maintenance respiration for models A; B & C
		# km is the maintenance respiration coefficient [d-1]
		p_km_ix = min(𝟙 / p_C2Nveg[ix] * RMN * fT, 𝟙)
		p_km4su_ix = p_km[ix] * YG

		# maintenance respiration first: R_m = km * C
		RA_M_ix = p_km_ix * cEco[ix]
	# no negative maintenance respiration
		RA_M_ix = max(RA_M_ix, 𝟘)

		# growth respiration: R_g = (1.0 - YG) * (GPP * allocationToPool - R_m)
		RA_G_ix = (𝟙 - YG) * (gpp * cAlloc[ix] - RA_M_ix)

		# no negative growth respiration
		RA_G_ix = max(RA_G_ix, 𝟘)

		# total respiration per pool: R_a = R_m + R_g
		cEcoEfflux = ups(cEcoEfflux, RA_M_ix + RA_G_ix, helpers.pools.carbon.zeros.cEco, helpers.pools.carbon.ones.cEco, helpers.numbers.𝟘, helpers.numbers.𝟙, ix)
		p_km = ups(p_km, p_km_ix, helpers.pools.carbon.zeros.cEco, helpers.pools.carbon.ones.cEco, helpers.numbers.𝟘, helpers.numbers.𝟙, ix)
		p_km4su = ups(p_km4su, p_km4su_ix, helpers.pools.carbon.zeros.cEco, helpers.pools.carbon.ones.cEco, helpers.numbers.𝟘, helpers.numbers.𝟙, ix)
		RA_M = ups(RA_M, RA_M_ix, helpers.pools.carbon.zeros.cEco, helpers.pools.carbon.ones.cEco, helpers.numbers.𝟘, helpers.numbers.𝟙, ix)
		RA_G = ups(RA_G, RA_G_ix, helpers.pools.carbon.zeros.cEco, helpers.pools.carbon.ones.cEco, helpers.numbers.𝟘, helpers.numbers.𝟙, ix)
		# cEcoEfflux[ix] = RA_M[ix] + RA_G[ix]
	end

	## pack land variables
	@pack_land begin
		(p_km, p_km4su) => land.aRespiration
		(RA_G, RA_M, cEcoEfflux) => land.states
	end
	return land
end

@doc """
Estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL A - maintenance respiration is given priority [check Fig.1 of the paper].

# Parameters
$(PARAMFIELDS)

---

# compute:
Determine growth and maintenance respiration using aRespiration_Thornley2000A

*Inputs*
 - info.timeScale.stepsPerDay: number of time steps per day
 - land.aRespirationAirT.fT: temperature effect on autrotrophic respiration [δT-1]
 - land.cCycleBase.C2Nveg: carbon to nitrogen ratio [gC.gN-1]
 - land.states.cAlloc: carbon allocation []
 - land.pools.cEco: ecosystem carbon pools [gC.m2]
 - land.fluxes.gpp: gross primary productivity [gC.m2.δT-1]

*Outputs*
 - land.states.cEcoEfflux: autotrophic respiration from each plant pools [gC.m-2.δT-1]
 - land.states.RA_G: growth respiration from each plant pools [gC.m-2.δT-1]
 - land.states.RA_M: maintenance respiration from each plant pools [gC.m-2.δT-1]

---

# Extended help

*References*
 - Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.  Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
 - Thornley, J. H. M., & M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation & realism, Ann Bot-London, 85[1]  55-67.

*Versions*
 - 1.0 on 06.05.2022 [ncarval/skoirala]: cleaned up the code

*Created by:*
 - ncarval

*Notes*
 - Questions - practical - leave raAct per pool; | make a field land.fluxes.ra  that has all the autotrophic respiration components together?  
"""
aRespiration_Thornley2000A