export gpp_mult, gpp_mult_h
"""
compute the actual GPP with potential scaled by multiplicative stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gpp_mult{T} <: gpp
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gpp_mult, forcing, land, infotem)
	# @unpack_gpp_mult o
	return land
end

function compute(o::gpp_mult, forcing, land, infotem)
	@unpack_gpp_mult o

	## unpack variables
	@unpack_land begin
		fAPAR ∈ land.states
		SMScGPP ∈ land.gppSoilW
		gppPot ∈ land.gppPotential
		AllDemScGPP ∈ land.gppDemand
	end
	AllScGPP = AllDemScGPP * SMScGPP; #sujan
	gpp = fAPAR * gppPot * AllScGPP

	## pack variables
	@pack_land begin
		gpp ∋ land.fluxes
		AllScGPP ∋ land.gpp
	end
	return land
end

function update(o::gpp_mult, forcing, land, infotem)
	# @unpack_gpp_mult o
	return land
end

"""
compute the actual GPP with potential scaled by multiplicative stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration]

# precompute:
precompute/instantiate time-invariant variables for gpp_mult

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_mult

*Inputs:*
 - land.gppDemand.AllDemScGPP: effective demand scalars; between 0-1
 - land.gppPotential.gppPot: maximum potential GPP based on radiation use efficiency
 - land.gppSoilW.SMScGPP: soil moisture stress scalar; between 0-1
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  [-] (equivalent to "canopy cover" in Gash & Miralles)

*Outputs:*
 - land.fluxes.gpp: actual GPP [gC/m2/time]

# update
update pools and states in gpp_mult
 - land.gpp.AllScGPP

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]

*Notes:*
"""
function gpp_mult_h end