export groundWRecharge_dos, groundWRecharge_dos_h
"""
calculates GW recharge as a fraction of soil moisture of the lowermost layer

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct groundWRecharge_dos{T1} <: groundWRecharge
	dos_exp::T1 = 1.0 | (0.1, 3.0) | "exponent of non-linearity for dos influence on drainage to groundwater" | ""
end

function precompute(o::groundWRecharge_dos, forcing, land, infotem)
	# @unpack_groundWRecharge_dos o
	return land
end

function compute(o::groundWRecharge_dos, forcing, land, infotem)
	@unpack_groundWRecharge_dos o

	## unpack variables
	@unpack_land begin
		(p_wSat, p_β) ∈ land.soilWBase
		(groundW, soilW) ∈ land.pools
	end
	# calculate recharge
	dosSoilEnd = soilW[infotem.pools.water.nZix.soilW] / p_wSat[infotem.pools.water.nZix.soilW]
	gwRec = ((dosSoilEnd) ^ (dos_exp * p_β[infotem.pools.water.nZix.soilW])) * soilW[infotem.pools.water.nZix.soilW]

	## pack variables
	@pack_land begin
		gwRec ∋ land.fluxes
	end
	return land
end

function update(o::groundWRecharge_dos, forcing, land, infotem)
	@unpack_groundWRecharge_dos o

	## unpack variables
	@unpack_land begin
		groundW ∈ land.pools
		gwRec ∈ land.fluxes
	end

	## update variables
	# update storages pool
	soilW[infotem.pools.water.nZix.soilW] = soilW[infotem.pools.water.nZix.soilW] - gwRec
	groundW[1] = groundW[1] + gwRec

	## pack variables
	@pack_land begin
		(groundW, soilW) ∋ land.pools
	end
	return land
end

"""
calculates GW recharge as a fraction of soil moisture of the lowermost layer

# precompute:
precompute/instantiate time-invariant variables for groundWRecharge_dos

# compute:
Recharge the groundwater using groundWRecharge_dos

*Inputs:*
 - land.pools.soilW
 - rf

*Outputs:*
 - land.fluxes.gwRec

# update
update pools and states in groundWRecharge_dos
 - land.pools.groundW[1]

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function groundWRecharge_dos_h end