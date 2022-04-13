export vegAvailableWater_rootFraction, vegAvailableWater_rootFraction_h
"""
sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants

# Parameters:
$(PARAMFIELDS)
"""

@bounds @describe @units @with_kw struct vegAvailableWater_rootFraction{T} <: vegAvailableWater
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::vegAvailableWater_rootFraction, forcing, land, infotem)
	@unpack_vegAvailableWater_rootFraction o

	## instantiate variables
	pawAct = ones(size(infotem.pools.water.initValues.soilW))

	## pack variables
	@pack_land begin
		pawAct ∋ land.vegAvailableWater
	end
	return land
end

function compute(o::vegAvailableWater_rootFraction, forcing, land, infotem)
	@unpack_vegAvailableWater_rootFraction o

	## unpack variables
	@unpack_land begin
		pw = pawAct ∈ land.vegAvailableWater
		p_wWP ∈ land.soilWBase
		p_fracRoot2SoilD ∈ land.rootFraction
		soilW ∈ land.pools
	end
	#--> create the arrays to fill with pawAct
	# #--> get the number of soil layers
	# infotem.pools.water.nZix.soilW = infotem.pools.water.nZix.soilW
	#
	# for sl = 1:infotem.pools.water.nZix.soilW
	# # soilWAvail = min(soilW[sl], p_wAWC[sl])
	# pawAct[sl] = p_fracRoot2SoilD[sl] * (max(soilW[sl] - p_wWP[sl], 0.0))
	# end
	
	pawAct = p_fracRoot2SoilD .* (max.(soilW - p_wWP, 0.0))

	# max(a, b)
	# max(avector, anothervector)
	## pack variables
	∈
	∋
	
	@pack_land begin
		pawAct = pw => land.states
	end
	return land
end


@doc 
"""
sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants

# precompute:
precompute/instantiate time-invariant variables for vegAvailableWater_rootFraction

# compute:
Plant available water using vegAvailableWater_rootFraction

*Inputs:*
 - land.pools.soilW
 - land.rootFraction.constantRootFrac
 - land.states.maxRootD
 - land.states.p_

*Outputs:*
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW
 - land.states.pawAct as nPix;nZix for soilW

# update
update pools and states in vegAvailableWater_rootFraction
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 21.11.2019  

*Created by:*
 - Sujan Koirala [skoirala]
""" 
vegAvailableWater_rootFraction