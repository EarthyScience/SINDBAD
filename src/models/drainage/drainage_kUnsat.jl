export drainage_kUnsat, drainage_kUnsat_h
"""
computes the downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct drainage_kUnsat{T} <: drainage
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::drainage_kUnsat, forcing, land, infotem)
	# @unpack_drainage_kUnsat o
	return land
end

function compute(o::drainage_kUnsat, forcing, land, infotem)
	@unpack_drainage_kUnsat o

	## unpack variables
	@unpack_land begin
		p_nsoilLayers ∈ land.soilWBase
		kUnsatFuncH ∈ land.soilProperties
		soilW ∈ land.pools
		soilWPerc ∈ land.fluxes
	end
	#--> get the number of soil layers
	infotem.pools.water.nZix.soilW = p_nsoilLayers
	soilWFlow[1] = soilWPerc
	for sl in 1:infotem.pools.water.nZix.soilW-1
		#--> get the drainage flux
		k_unsat = feval(kUnsatFuncH, s, p, info, sl)
		drain = min(k_unsat, soilW[sl])
		#--> store the drainage flux
		soilWFlow[sl+1] = drain
	end

	## pack variables
	@pack_land begin
		soilWFlow ∋ land.states
	end
	return land
end

function update(o::drainage_kUnsat, forcing, land, infotem)
	@unpack_drainage_kUnsat o

	## unpack variables
	@unpack_land begin
		(soilW[sl, 1], drain) ∈ land.fluxes
	end

	## update variables
		#--> update storages
		soilW[sl] = soilW[sl] - drain
		soilW[sl+1] = soilW[sl+1]+drain

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
computes the downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity

# precompute:
precompute/instantiate time-invariant variables for drainage_kUnsat

# compute:
Recharge the soil using drainage_kUnsat

*Inputs:*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.

*Outputs:*
 - drainage from the last layer is saved as groundwater recharge [gwRec]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update
update pools and states in drainage_kUnsat
 - land.pools.soilW

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function drainage_kUnsat_h end