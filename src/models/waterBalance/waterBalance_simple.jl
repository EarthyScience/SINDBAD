export waterBalance_simple, waterBalance_simple_h
"""
check the water balance in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct waterBalance_simple{T} <: waterBalance
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::waterBalance_simple, forcing, land, infotem)
	# @unpack_waterBalance_simple o
	return land
end

function compute(o::waterBalance_simple, forcing, land, infotem)
	@unpack_waterBalance_simple o

	## unpack variables
	@unpack_land begin
		snow ∈ land.rainSnow
		(wTotal, wTotal_prev) ∈ land.pools
		(evapotranspiration, runoff) ∈ land.fluxes
	end
	precip = snow + snow
	dS = wTotal - wTotal_prev
	waterBalance = precip-runoff - evapotranspiration - dS

	## pack variables
	@pack_land begin
		waterBalance ∋ land.waterBalance
	end
	return land
end

function update(o::waterBalance_simple, forcing, land, infotem)
	# @unpack_waterBalance_simple o
	return land
end

"""
check the water balance in every time step

# precompute:
precompute/instantiate time-invariant variables for waterBalance_simple

# compute:
Calculate the water balance using waterBalance_simple

*Inputs:*
 - check if snow exists to calculate p = rain+snow
 - info
 - tix
 - variables to sum for runoff[total runoff] & evapotranspiration [total evap]

*Outputs:*
 - add to variables to store
 - land.waterBalance.wBal in nPix;nZix

# update
update pools and states in waterBalance_simple
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019
 - 1.1 on 20.11.2019 [skoirala]: use tix for WP because land.[module].[var]  is created as nPix;nTix

*Created by:*
 - Martin Jung [mjung]
"""
function waterBalance_simple_h end