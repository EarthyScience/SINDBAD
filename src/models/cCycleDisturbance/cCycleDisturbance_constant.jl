export cCycleDisturbance_constant, cCycleDisturbance_constant_h
"""
placeholder for scaling the carbon pools with a constant to emulate steady state jump. Actual scaling is done at the end of spinup; but the parameters are written here to bypass setupcode checks & use them in optimization In dyna; the disturbance of cVeg parameters is implemented based on forcing. the disturbance of cVeg parameters is implemented based on forcing

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cCycleDisturbance_constant{T1} <: cCycleDisturbance
	carbon_remain::T1 = 10.0 | (0.1, 100.0) | "remaining carbon after disturbance" | ""
end

function precompute(o::cCycleDisturbance_constant, forcing, land, infotem)
	@unpack_cCycleDisturbance_constant o
	@unpack_land begin
		isDisturbed ∈ forcing
	end
	@unpack_land begin
		cEco ∈ land.pools
		(p_giver, p_taker) ∈ land.cFlow
	end

	## calculate variables
	zixVecVeg = infotem.pools.carbon.zix.cVeg
	for zixVeg in zixVecVeg
		cLoss = max(cEco[zixVeg]-carbon_remain, 0.0) * (isDisturbed)
		cEco[zixVeg] = cEco[zixVeg] - cLoss
		ndxLoseToZix = p_taker[p_giver == zixVeg]
		for tZ in 1:length(ndxLoseToZix)
			tarZix = ndxLoseToZix[tZ]
			if !any(zixVecVeg == tarZix)
				cEco[tarZix] = cEco[tarZix] + cLoss
			end
		end
	end

	## pack variables
	return land
end

function compute(o::cCycleDisturbance_constant, forcing, land, infotem)
	# @unpack_cCycleDisturbance_constant o
	return land
end

function update(o::cCycleDisturbance_constant, forcing, land, infotem)
	# @unpack_cCycleDisturbance_constant o
	return land
end

"""
placeholder for scaling the carbon pools with a constant to emulate steady state jump. Actual scaling is done at the end of spinup; but the parameters are written here to bypass setupcode checks & use them in optimization In dyna; the disturbance of cVeg parameters is implemented based on forcing. the disturbance of cVeg parameters is implemented based on forcing

# precompute:
precompute/instantiate time-invariant variables for cCycleDisturbance_constant

# compute:
Disturb the carbon cycle pools using cCycleDisturbance_constant

*Inputs:*
 - land.cCycleScale.etaA: scaling parameter for vegetation pools
 - land.cCycleScale.etaH: scaling parameter for heterotrophic pools
 - land.pools.cEco: carbon pool at the end of spinup

*Outputs:*
 -

# update
update pools and states in cCycleDisturbance_constant
 - land.pools.cEco

# Extended help

*References:*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].

*Versions:*
 - 1.0 on 23.04.2021 [skoirala]
 - 1.0 on 23.04.2021 [skoirala]  
 - 1.1 on 29.11.2021 [skoirala]: moved the scaling parameters to  ccyclebase_gsi [land.cCycleBase.etaA & land.cCycleBase.etaH]  

*Created by:*
 - skoirala
"""
function cCycleDisturbance_constant_h end