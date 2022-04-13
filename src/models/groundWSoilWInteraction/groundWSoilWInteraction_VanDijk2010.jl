export groundWSoilWInteraction_VanDijk2010, groundWSoilWInteraction_VanDijk2010_h
"""
calculates the upward flow of water from groundwater to lowermost soil layer

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct groundWSoilWInteraction_VanDijk2010{T} <: groundWSoilWInteraction
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::groundWSoilWInteraction_VanDijk2010, forcing, land, infotem)
	# @unpack_groundWSoilWInteraction_VanDijk2010 o
	return land
end

function compute(o::groundWSoilWInteraction_VanDijk2010, forcing, land, infotem)
	@unpack_groundWSoilWInteraction_VanDijk2010 o

	## unpack variables
	@unpack_land begin
		(p_kFC, p_kSat, p_wSat) ∈ land.soilWBase
		(groundW, soilW) ∈ land.pools
	end
	#--> index of the last soil layer
	soilWend = infotem.pools.water.nZix.soilW
	#--> degree of saturation & unsaturated hydraulic conductivity of the lowermost soil layer
	dosSoilend = soilW[soilWend] / p_wSat[soilWend]
	# k_unsat = feval(kUnsatFuncH, s, p, info, soilWend)
	k_sat = p_kSat[soilWend]; #GW is saturated
	k_fc = p_kFC[soilWend]; #GW is saturated
	#--> get the capillary flux
	# c_flux = sqrt(k_unsat * k_sat) * (1.0 - dosSoilend)
	c_flux = k_fc * (1.0 - dosSoilend)
	c_flux = minimum(c_flux, groundW[1])
	#--> store the net recharge & capillary flux
	gwRec = gwRec - c_flux
	gwCflux = c_flux
	#--> adjust the storages

	## pack variables
	@pack_land begin
		(gwCflux, gwRec) ∋ land.fluxes
	end
	return land
end

function update(o::groundWSoilWInteraction_VanDijk2010, forcing, land, infotem)
	@unpack_groundWSoilWInteraction_VanDijk2010 o

	## unpack variables
	@unpack_land begin
		groundW ∈ land.pools
		c_flux ∈ land.fluxes
	end

	## update variables
	soilW[soilWend] = soilW[soilWend]+c_flux
	groundW[1] = groundW[1] - c_flux

	## pack variables
	@pack_land begin
		(groundW, soilW) ∋ land.pools
	end
	return land
end

"""
calculates the upward flow of water from groundwater to lowermost soil layer

# precompute:
precompute/instantiate time-invariant variables for groundWSoilWInteraction_VanDijk2010

# compute:
Groundwater soil moisture interactions (e.g. capilary flux, water using groundWSoilWInteraction_VanDijk2010

*Inputs:*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.

*Outputs:*
 - land.fluxes.gwClux: capillary flux
 - land.fluxes.gwRec: net groundwater recharge

# update
update pools and states in groundWSoilWInteraction_VanDijk2010
 - land.fluxes.gwRec
 - land.pools.groundW[1]
 - land.pools.soilW

# Extended help

*References:*
 - AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model [version 0.5] Technical Description
 - http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function groundWSoilWInteraction_VanDijk2010_h end