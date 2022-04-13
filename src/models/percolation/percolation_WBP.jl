export percolation_WBP, percolation_WBP_h
"""
computes the percolation into the soil after the surface runoff & evaporation processes are complete

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct percolation_WBP{T} <: percolation
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::percolation_WBP, forcing, land, infotem)
	# @unpack_percolation_WBP o
	return land
end

function compute(o::percolation_WBP, forcing, land, infotem)
	@unpack_percolation_WBP o

	## unpack variables
	@unpack_land begin
		WBP ∈ land.states
		(p_nsoilLayers, p_wSat) ∈ land.soilWBase
		soilW ∈ land.pools
	end
	#--> get the number of soil layers
	infotem.pools.water.nZix.soilW = p_nsoilLayers
	#--> set WBP as the soil percolation
	soilWPerc = WBP
	#--> update the soil moisture in the first layer
	#--> calculate the oversaturation of the first layer
	soilWExc = max(soilW[1]-p_wSat[1], 0.0)
	#--> reallocate excess moisture of 1st layer to deeper layers
	for sl in 1:infotem.pools.water.nZix.soilW
		ip = min(p_wSat[sl] - soilW[sl], soilWExc)
		soilWExc = soilWExc - ip
	end
	WBP = soilWExc
	#--> if the excess moisture is larger than the soil storage capacity; add that amount to GW storage
	# groundW[1] = groundW[1] + WBP
	# what should be done if there is still more water?
	# if sum(soilWExc) > 0.001
	# disp([pad[" CRIT MODEL RUN", 20, "left"] " : " pad["soilWPerc_WBP", 20] " | the excess overflow of the percolation does not fit in the soil storage"])
	# end

	## pack variables
	@pack_land begin
		soilWPerc ∋ land.fluxes
		WBP ∋ land.states
	end
	return land
end

function update(o::percolation_WBP, forcing, land, infotem)
	@unpack_percolation_WBP o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		ip ∈ land.fluxes
	end

	## update variables
	soilW[1] = soilW[1] + soilWPerc
	soilW[1] = soilW[1] - soilWExc
		soilW[sl] = soilW[sl] + ip

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
computes the percolation into the soil after the surface runoff & evaporation processes are complete

# precompute:
precompute/instantiate time-invariant variables for percolation_WBP

# compute:
Calculate the soil percolation = wbp at this point using percolation_WBP

*Inputs:*
 - land.states.WBP: water budget pool

*Outputs:*
 - land.fluxes.soilWPerc: soil percolation

# update
update pools and states in percolation_WBP
 - land.pools.soilW
 - land.states.WBP

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function percolation_WBP_h end