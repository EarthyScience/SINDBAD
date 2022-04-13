export vegAvailableWater_sigmoid, vegAvailableWater_sigmoid_h
"""
calculate the actual amount of water that is available for plants

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegAvailableWater_sigmoid{T1} <: vegAvailableWater
	exp_factor::T1 = 1.0 | (0.02, 3.0) | "multiplier of B factor of exponential rate" | ""
end

function precompute(o::vegAvailableWater_sigmoid, forcing, land, infotem)
	@unpack_vegAvailableWater_sigmoid o

	## instantiate variables
	pawAct = ones(size(infotem.pools.water.initValues.soilW))
	soilWStress = ones(size(infotem.pools.water.initValues.soilW))

	## pack variables
	@pack_land begin
		(pawAct, soilWStress) ∋ land.vegAvailableWater
	end
	return land
end

function compute(o::vegAvailableWater_sigmoid, forcing, land, infotem)
	@unpack_vegAvailableWater_sigmoid o

	## unpack variables
	@unpack_land begin
		(pawAct, soilWStress) ∈ land.vegAvailableWater
		soilWStress ∈ land.states
		(p_wFC, p_wSat, p_β) ∈ land.soilWBase
		p_fracRoot2SoilD ∈ land.rootFraction
		soilW ∈ land.pools
	end
	#--> create the arrays to fill with pawAct
	θ_dos = soilW / p_wSat
	θ_fc_dos = p_wFC / p_wSat
	soilWStress = 1 / (1 + exp(-p_β * (θ_dos-θ_fc_dos)))
	pawAct = p_fracRoot2SoilD * soilW * soilWStress

	## pack variables
	@pack_land begin
		(pawAct, soilWStress) ∋ land.states
	end
	return land
end

function update(o::vegAvailableWater_sigmoid, forcing, land, infotem)
	# @unpack_vegAvailableWater_sigmoid o
	return land
end

"""
calculate the actual amount of water that is available for plants

# precompute:
precompute/instantiate time-invariant variables for vegAvailableWater_sigmoid

# compute:
Plant available water using vegAvailableWater_sigmoid

*Inputs:*
 - land.pools.soilW
 - land.states.p_

*Outputs:*
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW

# update
update pools and states in vegAvailableWater_sigmoid
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 21.11.2019  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function vegAvailableWater_sigmoid_h end