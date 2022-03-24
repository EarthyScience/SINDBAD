export aRespiration_Thornley2000B

@bounds @describe @units @with_kw struct aRespiration_Thornley2000B{T1, T2} <: aRespiration
	RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/day"
	YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC"
end


function precompute(o::aRespiration_Thornley2000B, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_land begin
		cEco ∈ land.pools
		numType ∈ helpers.numbers
	end
	
	p_km = ones(numType, length(land.pools.cEco))
	p_km4su = copy(p_km)
	RA_G = copy(p_km)
	RA_M = copy(p_km)

	## pack land variables
	@pack_land begin
		(p_km, p_km4su) => land.aRespiration
		(RA_G, RA_M) => land.states
	end
	return land
end

function compute(o::aRespiration_Thornley2000B, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_aRespiration_Thornley2000B o

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
	
	# adjust nitrogen efficiency rate of maintenance respiration
	RMN = RMN / helpers.dates.nStepsDay
	
	# compute maintenance & growth respiration terms for each vegetation pool
	# according to MODEL B - growth respiration is given priority
	zix = getzix(land.pools.cVeg)

	# scalars of maintenance respiration for models A; B & C
	# km is the maintenance respiration coefficient [d-1]
	p_km[zix] .= 𝟙 ./ p_C2Nveg[zix] .* RMN .* fT
	p_km4su[zix] .= p_km[zix]

	# growth respiration: R_g = (1.0 - YG) * GPP * allocationToPool
	RA_G[zix] .= (𝟙 - YG) .* gpp .* cAlloc[zix]

	# maintenance respiration: R_m = km * (C + YG * GPP * allocationToPool)
	RA_M[zix] .= p_km[zix] .* (cEco[zix] .+ YG .* gpp .* cAlloc[zix])

	# no negative growth or maintenance respiration
	RA_G .= max.(RA_G, 𝟘)
	RA_M .= max.(RA_M, 𝟘)

	# total respiration per pool: R_a = R_m + R_g
	cEcoEfflux[zix] .= RA_M[zix] .+ RA_G[zix]

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
Determine growth and maintenance respiration using aRespiration_Thornley2000B (model B)

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
 -  
"""
aRespiration_Thornley2000B