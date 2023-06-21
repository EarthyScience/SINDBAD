export cCycleDisturbance_WROASTED

@bounds @describe @units @with_kw struct cCycleDisturbance_WROASTED{T1} <: cCycleDisturbance
	carbon_remain::T1 = 10.0 | (0.1, 100.0) | "remaining carbon after disturbance" | ""
end

function instantiate(o::cCycleDisturbance_WROASTED, forcing, land, helpers)
	@unpack_land begin
		(giver, taker) ∈ land.cCycleBase
	end
	zixVegAll = Tuple(vcat(getzix(getfield(land.pools, :cVeg), helpers.pools.zix.cVeg)...))
	ndxLoseToZixVec = []
	for _ in zixVegAll
		push!(ndxLoseToZixVec, getzix(land.pools.cSoilSlow, helpers.pools.zix.cSoilSlow))
	end
	ndxLoseToZixVec = Tuple(ndxLoseToZixVec)
	@pack_land (zixVegAll, ndxLoseToZixVec) => land.cCycleDisturbance
	return land
end

function compute(o::cCycleDisturbance_WROASTED, forcing, land, helpers)
	## unpack parameters and forcing
	@unpack_cCycleDisturbance_WROASTED o
	@unpack_forcing isDisturbed ∈ forcing

	## unpack land variables
	@unpack_land begin
		(zixVegAll, ndxLoseToZixVec) ∈ land.cCycleDisturbance
		cEco ∈ land.pools
		(giver, taker) ∈ land.cFlow
		𝟘 ∈ helpers.numbers
	end
	if isDisturbed > 𝟘
		# @show "before", cEco, sum(cEco)
		for zixVeg in zixVegAll
            cLoss = max(cEco[zixVeg]-carbon_remain, 𝟘) * isDisturbed
			@add_to_elem -cLoss => (cEco, zixVeg, :cEco)
			ndxLoseToZix = ndxLoseToZixVec[zixVeg]
			for tZ in eachindex(ndxLoseToZix)
				tarZix = ndxLoseToZix[tZ]
				toGain = cLoss / length(ndxLoseToZix)
				@add_to_elem toGain => (cEco, tarZix, :cEco)
			end
		end
		# @show "after", cEco, sum(cEco)
		
	end
	## pack land variables
	@pack_land cEco => land.pools
	return land
end

function update(o::cCycleDisturbance_WROASTED, forcing, land, helpers)
	@unpack_cCycleDisturbance_WROASTED o

	## unpack variables
	@unpack_land begin
		cEco ∈ land.pools
		cLoss ∈ land.fluxes
	end

	## update variables
		cEco[zixVeg] = cEco[zixVeg] - cLoss
				cEco[tarZix] = cEco[tarZix] + cLoss

	## pack land variables
	@pack_land cEco => land.pools
	return land
end

@doc """
move all vegetation carbon in excess of carbon_remain to cSoilSlow in case of disturbance

# Parameters
$(PARAMFIELDS)

---

# compute:
Disturb the carbon cycle pools using cCycleDisturbance_WROASTED

*Inputs*
 - land.pools.cEco: carbon pool at the end of spinup

*Outputs*

# update

update pools and states in cCycleDisturbance_WROASTED

 - land.pools.cEco

---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].

*Versions*
 - 1.0 on 23.06.2023 [skoirala]

*Created by:*
 - skoirala
"""
cCycleDisturbance_WROASTED