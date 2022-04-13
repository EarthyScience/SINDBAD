export drainage_dos, drainage_dos_h
"""
computes the downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct drainage_dos{T1} <: drainage
	dos_exp::T1 = 1.0 | (0.1, 3.0) | "exponent of non-linearity for dos influence on drainage in soil" | ""
end

function precompute(o::drainage_dos, forcing, land, infotem)
	# @unpack_drainage_dos o
	return land
end

function compute(o::drainage_dos, forcing, land, infotem)
	@unpack_drainage_dos o

	## unpack variables
	@unpack_land begin
		(p_nsoilLayers, p_wSat, p_β) ∈ land.soilWBase
		soilW ∈ land.pools
		soilWPerc ∈ land.fluxes
	end
	#--> get the number of soil layers
	infotem.pools.water.nZix.soilW = p_nsoilLayers
	soilWFlow[1] = soilWPerc
	dos_soil = soilW / p_wSat
	drain_full = ((dos_soil) ^ (dos_exp * p_β)) * soilW
	for sl in 1:infotem.pools.water.nZix.soilW-1
		#--> get the drainage flux
		drain = drain_full[sl]
		# k_unsat = feval(kUnsatFuncH, s, p, info, sl)
		# drain = min(k_unsat, soilW[sl])
		#--> store the drainage flux
		soilWFlow[sl+1] = drain
		drain = min(drain, p_wSat[sl+1] - soilW[sl+1])
	end
	#
	#
	# for sl = 1:infotem.pools.water.nZix.soilW-1
	# #--> get the drainage flux
	# dosSoil = soilW[sl] / p_wSat[sl]
	#
	# drain = ((dosSoil) ^ (dos_exp * p_β[sl])) * soilW[sl]
	#
	# # k_unsat = feval(kUnsatFuncH, s, p, info, sl)
	# # drain = min(k_unsat, soilW[sl])
	# #--> store the drainage flux
	# soilWFlow[sl+1] = drain
	# drain = min(drain, p_wSat[sl+1] - soilW[sl+1])
	# soilW[sl] = soilW[sl] - drain
	# soilW[sl+1] = soilW[sl+1]+drain
	# end

	## pack variables
	@pack_land begin
		soilWFlow ∋ land.states
	end
	return land
end

function update(o::drainage_dos, forcing, land, infotem)
	@unpack_drainage_dos o

	## unpack variables
	@unpack_land begin
		(soilW[sl, 1], drain) ∈ land.fluxes
	end

	## update variables
		#--> update storages
		soilW[sl] = soilW[sl] - drain
		soilW[sl+1] = soilW[sl+1]+drain
	# #--> update storages

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
computes the downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity

# precompute:
precompute/instantiate time-invariant variables for drainage_dos

# compute:
Recharge the soil using drainage_dos

*Inputs:*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.

*Outputs:*
 - drainage from the last layer is saved as groundwater recharge [gwRec]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update
update pools and states in drainage_dos
 - land.pools.soilW

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function drainage_dos_h end