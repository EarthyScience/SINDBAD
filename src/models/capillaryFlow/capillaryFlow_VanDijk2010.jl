export capillaryFlow_VanDijk2010, capillaryFlow_VanDijk2010_h
"""
computes the upward water flow in the soil layers

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct capillaryFlow_VanDijk2010{T} <: capillaryFlow
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::capillaryFlow_VanDijk2010, forcing, land, infotem)
	# @unpack_capillaryFlow_VanDijk2010 o
	return land
end

function compute(o::capillaryFlow_VanDijk2010, forcing, land, infotem)
	@unpack_capillaryFlow_VanDijk2010 o

	## unpack variables
	@unpack_land begin
		soilWFlow ∈ land.states
		(p_kFC, p_wSat) ∈ land.soilWBase
		soilW ∈ land.pools
	end
	soilWend = infotem.pools.water.nZix.soilW
	for sl in soilWend:-1:2
		#--> calculate the capillary flux
		# k_unsat_lower = feval(kUnsatFuncH, s, p, info, sl)
		dosSoilUpper = soilW[sl-1] / p_wSat[sl-1]
		# k_unsat_upper = feval(kUnsatFuncH, s, p, info, sl-1)
		# c_flux = sqrt(k_unsat_lower * k_unsat_upper) * (1.0 - dosSoilUpper)
		# modified by sujan 01.12.2020
		k_fc = p_kFC[sl]; # GW is saturated
		c_flux = k_fc * (1.0 - dosSoilUpper)
		c_flux = min(c_flux, soilW[sl])
		#--> update the soil flow to have a net between drainage & capillary flux
		soilWFlow[sl] = soilWFlow[sl]-c_flux
	end

	## pack variables
	@pack_land begin
		soilWFlow ∋ land.states
	end
	return land
end

function update(o::capillaryFlow_VanDijk2010, forcing, land, infotem)
	@unpack_capillaryFlow_VanDijk2010 o

	## unpack variables
	@unpack_land begin
		(soilW[sl, 1], c_flux) ∈ land.fluxes
	end

	## update variables
		#--> update storages
		soilW[sl] = soilW[sl]-c_flux
		soilW[sl-1] = soilW[sl-1]+c_flux

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
computes the upward water flow in the soil layers

# precompute:
precompute/instantiate time-invariant variables for capillaryFlow_VanDijk2010

# compute:
Flux of water from lower to upper soil layers (upward soil moisture movement) using capillaryFlow_VanDijk2010

*Inputs:*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.

*Outputs:*
 -

# update
update pools and states in capillaryFlow_VanDijk2010
 - land.pools.soilW
 - land.states.soilWFlow: drainage flux between soil layers [from soilWRec] is adjusted to reflect  upward capillary flux

# Extended help

*References:*
 - AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model [version 0.5] Technical Description
 - http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function capillaryFlow_VanDijk2010_h end