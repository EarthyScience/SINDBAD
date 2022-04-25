export aRespiration_Thornley2000A

@bounds @describe @units @with_kw struct aRespiration_Thornley2000A{T1, T2} <: aRespiration
	RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/day"
	YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC"
end

function compute(o::aRespiration_Thornley2000A, forcing, land, helpers)
	## unpack parameters
	@unpack_aRespiration_Thornley2000A o

	## unpack land variables
	@unpack_land begin
		(cAlloc, cEcoEfflux) ∈ land.states
		cEco ∈ land.pools
		gpp ∈ land.fluxes
		p_C2Nveg ∈ land.cCycleBase
		fT ∈ land.aRespirationAirT
		(one, zero, numType) ∈ helpers.numbers
	end
	p_km = ones(numType, length(land.pools.cEco))
	p_km4su = p_km
	RA_G = p_km
	RA_M = p_km
	# adjust nitrogen efficiency rate of maintenance respiration to the current
	# model time step
	RMN = RMN / helpers.dates.nStepsDay
	
	# compute maintenance & growth respiration terms for each vegetation pool
	# according to MODEL A - maintenance respiration is given priority
	zix = getzix(land.pools.cVeg)

	# scalars of maintenance respiration for models A; B & C
	# km is the maintenance respiration coefficient [d-1]
	p_km[zix] .= one ./ p_C2Nveg[zix] .* RMN .* fT
	p_km4su[zix] .= p_km[zix] .* YG
	
	# maintenance respiration first: R_m = km * C
	RA_M[zix] .= p_km[zix] .* cEco[zix]
	
	# growth respiration: R_g = (1.0 - YG) * (GPP * allocationToPool - R_m)
	RA_G[zix] .= (one - YG) .* (gpp .* cAlloc[zix] .- RA_M[zix])
	
	# no negative growth respiration
	RA_G .= max.(RA_G, zero)

	# total respiration per pool: R_a = R_m + R_g
	cEcoEfflux .= RA_M .+ RA_G

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
Determine growth and maintenance respiration -> npp using aRespiration_Thornley2000A

*Inputs*
 - land.aRespiration.km[ii].value: maintenance [respiration] coefficient - dependent on  temperature and; depending on the models; degradable fraction  (δT-1)
 - land.fluxes.gpp: substrate supply rate: Gross Primary Production [gC.m-2.δT-1]
 - land.pools.cEco: carbon pools [gC.m-2]
 - land.states.cAlloc[zix]: carbon allocation in the different vegetation pools [[]]

*Outputs*
 - land.states.cEcoEfflux[zix]: autotrophic respiration from each plant pools [gC.m-2.δT-1]
 - land.states.cNPP: net primary production for each plant pool [gC.m-2.δT-1]

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
 - Questions - practical - leave raAct per pool; | make a field land.fluxes.ra  that has all the autotrophic respiration components together?  
"""
aRespiration_Thornley2000A