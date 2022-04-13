export gpp_none, gpp_none_h
"""
sets the actual GPP to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gpp_none{T} <: gpp
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gpp_none, forcing, land, infotem)
	@unpack_gpp_none o

	## calculate variables
	gpp = 0.0

	## pack variables
	@pack_land begin
		gpp ∋ land.fluxes
	end
	return land
end

function compute(o::gpp_none, forcing, land, infotem)
	# @unpack_gpp_none o
	return land
end

function update(o::gpp_none, forcing, land, infotem)
	# @unpack_gpp_none o
	return land
end

"""
sets the actual GPP to zeros

# precompute:
precompute/instantiate time-invariant variables for gpp_none

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_none

*Inputs:*
 - info

*Outputs:*
 - land.fluxes.gpp: actual GPP [gC/m2/time]

# update
update pools and states in gpp_none
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - Nuno Carvalhais [ncarval]
"""
function gpp_none_h end