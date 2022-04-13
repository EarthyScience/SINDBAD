export groundWSoilWInteraction_none, groundWSoilWInteraction_none_h
"""
sets the groundwater capillary flux to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct groundWSoilWInteraction_none{T} <: groundWSoilWInteraction
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::groundWSoilWInteraction_none, forcing, land, infotem)
	@unpack_groundWSoilWInteraction_none o

	## calculate variables
	gwCflux = 0.0

	## pack variables
	@pack_land begin
		gwCflux ∋ land.fluxes
	end
	return land
end

function compute(o::groundWSoilWInteraction_none, forcing, land, infotem)
	# @unpack_groundWSoilWInteraction_none o
	return land
end

function update(o::groundWSoilWInteraction_none, forcing, land, infotem)
	# @unpack_groundWSoilWInteraction_none o
	return land
end

"""
sets the groundwater capillary flux to zeros

# Extended help
"""
function groundWSoilWInteraction_none_h end