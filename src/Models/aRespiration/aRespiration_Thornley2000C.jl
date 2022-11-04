export aRespiration_Thornley2000C

@bounds @describe @units @with_kw struct aRespiration_Thornley2000C{T1, T2} <: aRespiration
	RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/day"
	YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC"
end

function precompute(o::aRespiration_Thornley2000C, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)
	@unpack_land begin
		cEco ∈ land.pools
		numType ∈ helpers.numbers
	end
	
	p_km = ones(numType, length(land.pools.cEco))
	p_km4su = copy(p_km)
	RA_G = copy(p_km)
	RA_M = copy(p_km)
	Fd = copy(p_km)

	## pack land variables
	@pack_land begin
		(p_km, p_km4su, Fd) => land.aRespiration
		(RA_G, RA_M) => land.states
	end
	return land
end

function compute(o::aRespiration_Thornley2000C, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_aRespiration_Thornley2000C o

	## unpack land variables
	@unpack_land begin
		(p_km, p_km4su, Fd) ∈ land.aRespiration
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
	# according to MODEL C - growth; degradation & resynthesis view of
	# respiration
	zix = getzix(land.pools.cVeg)
	
	#@needscheck: MTF, metabolic fraction, may be inconsistent with the rest of the model structure
	Fd[zix] .= 𝟙
	## make the Fd of each pool equal to the MTF
	#if flagMTF
	#	Fd[zix] .= MTF
	#else
	#   Fd[zix] .= 1.0
	#end
	
	# scalars of maintenance respiration for models A; B & C
	# km is the maintenance respiration coefficient [d-1]
	km = 𝟙 ./ p_C2Nveg[zix] .* RMN .* fT
	kd = Fd[zix]
	p_km[zix] .= km .* kd
	p_km4su[zix] .= p_km[zix] .* (𝟙 - YG)

	# maintenance respiration: R_m = km * (1.0 - YG) * C; km = km * MTF [before equivalent to kd]
	RA_M[zix] .= p_km[zix] .* (𝟙 - YG) .* cEco[zix]

	# growth respiration: R_g = gpp * (1.0 - YG)
	RA_G[zix] .= (𝟙 - YG) .* gpp .* cAlloc[zix]
	
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
Precomputations to estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell (2000): MODEL C - growth, degradation & resynthesis view of respiration (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient]

# Parameters
$(PARAMFIELDS)

---

# compute:
Determine growth and maintenance respiration using aRespiration_Thornley2000C (model C)

*Inputs*
 - info.timeScale.stepsPerDay: number of time steps per day
 - land.aRespirationAirT.fT: temperature effect on autrotrophic respiration [δT-1]
 - land.cCycle.MTF: metabolic fraction []
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
 - Another thing to consider is if this a double count; since we have C2N  ratios?
 - Fd is the decomposable fraction from each plant pool [see Thornley and Cannell 2000]. Since we dont discriminate in the model, this should be based on literature values [e.g. sap to hard wood ratios]. Before this fraction was made equivalent to the metabolic fraction in residues -strong assumption. Until somebody looks at this, we keep the same approach & add a flag to model parameters to switch it off.
"""
aRespiration_Thornley2000C