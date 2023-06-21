export cCycleDisturbance_cFlow

@bounds @describe @units @with_kw struct cCycleDisturbance_cFlow{T1} <: cCycleDisturbance
	carbon_remain::T1 = 10.0 | (0.1, 100.0) | "remaining carbon after disturbance" | ""
end

function instantiate(o::cCycleDisturbance_cFlow, forcing, land, helpers)
	@unpack_land begin
		(giver, taker) ∈ land.cCycleBase
	end
	zixVegAll = Tuple(vcat(getzix(getfield(land.pools, :cVeg), helpers.pools.zix.cVeg)...))
	ndxLoseToZixVec = []
	for zixVeg in zixVegAll
		ndxLoseToZix = taker[[(giver .== zixVeg)...]]
		ndxNoVeg = []
		for ndxl in ndxLoseToZix
			if ndxl ∉ zixVegAll
				push!(ndxNoVeg, ndxl)
			end
		end
		push!(ndxLoseToZixVec, Tuple(ndxNoVeg))
	end
	ndxLoseToZixVec = Tuple(ndxLoseToZixVec)
	@pack_land (zixVegAll, ndxLoseToZixVec) => land.cCycleDisturbance
	return land
end

function compute(o::cCycleDisturbance_cFlow, forcing, land, helpers)
	## unpack parameters and forcing
	@unpack_cCycleDisturbance_cFlow o
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
			cLoss = 𝟘 # do not lose carbon if reserve pool
			if helpers.pools.components.cEco[zixVeg] !== :cVegReserve
				cLoss = max(cEco[zixVeg]-carbon_remain, 𝟘) * isDisturbed
			end
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

function update(o::cCycleDisturbance_cFlow, forcing, land, helpers)
	@unpack_cCycleDisturbance_cFlow o

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
move all vegetation carbon pools except reserve to respective flow target when there is disturbance

# Parameters
$(PARAMFIELDS)

---

# compute:
Disturb the carbon cycle pools using cCycleDisturbance_cFlow

*Inputs*
 - land.pools.cEco: carbon pool at the end of spinup

*Outputs*

# update

update pools and states in cCycleDisturbance_cFlow

 - land.pools.cEco

---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].

*Versions*
 - 1.0 on 23.04.2021 [skoirala]
 - 1.0 on 23.04.2021 [skoirala]  
 - 1.1 on 29.11.2021 [skoirala]: moved the scaling parameters to  ccyclebase_gsi [land.cCycleBase.ηA & land.cCycleBase.ηH]  

*Created by:*
 - skoirala
"""
cCycleDisturbance_cFlow