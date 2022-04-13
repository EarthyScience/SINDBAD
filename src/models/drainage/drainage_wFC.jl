export drainage_wFC, drainage_wFC_h
"""
computes the downward flow of moisture [drainage] in soil layers based on overflow from the upper layers

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct drainage_wFC{T} <: drainage
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::drainage_wFC, forcing, land, infotem)
	# @unpack_drainage_wFC o
	return land
end

function compute(o::drainage_wFC, forcing, land, infotem)
	@unpack_drainage_wFC o

	## unpack variables
	@unpack_land begin
		(p_nsoilLayers, p_wFC) ∈ land.soilWBase
		soilW ∈ land.pools
		soilWPerc ∈ land.fluxes
	end
	#--> get the number of soil layers
	infotem.pools.water.nZix.soilW = p_nsoilLayers
	soilWFlow[1] = soilWPerc
	for sl in 1:infotem.pools.water.nZix.soilW-1
		#--> drain excess moisture in oversaturation
		maxDrain = max(soilW[sl] - p_wFC[sl], 0)
		#--> store the drainage flux
		soilWFlow[sl+1] = maxDrain
	end

	## pack variables
	@pack_land begin
		soilWFlow ∋ land.states
	end
	return land
end

function update(o::drainage_wFC, forcing, land, infotem)
	@unpack_drainage_wFC o

	## unpack variables
	@unpack_land begin
		(soilW[sl, 1], maxDrain) ∈ land.fluxes
	end

	## update variables
		#--> update storages
		soilW[sl] = soilW[sl] - maxDrain
		soilW[sl+1] = soilW[sl+1] + maxDrain

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
computes the downward flow of moisture [drainage] in soil layers based on overflow from the upper layers

# precompute:
precompute/instantiate time-invariant variables for drainage_wFC

# compute:
Recharge the soil using drainage_wFC

*Inputs:*
 - land.pools.soilW: soil moisture in different layers
 - land.soilWBase.p_wFC: field capacity of soil in mm
 - land.states.WBP amount of water that can potentially drain

*Outputs:*
 - drainage from the last layer is saved as groundwater recharge [gwRec]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update
update pools and states in drainage_wFC
 - land.pools.soilW
 - land.states.WBP

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]: clean up & consistency  

*Created by:*
 - Martin Jung [mjung]
 - Sujan Koirala [skoirala]
"""
function drainage_wFC_h end