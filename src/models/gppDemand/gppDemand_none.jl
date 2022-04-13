export gppDemand_none, gppDemand_none_h
"""
sets the scalar for demand GPP to ones & demand GPP to zeros. sets the scalar for demand GPP to ones & demand GPP to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppDemand_none{T} <: gppDemand
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gppDemand_none, forcing, land, infotem)
	@unpack_gppDemand_none o
	@unpack_land begin
		fAPAR ∈ land.states
		gppPot ∈ land.gppPotential
	end

	## calculate variables
	#--> set scalar to a constant one [no effect on potential GPP]
	scall = repeat([1.0], 1, 4)
	AllDemScGPP = 1.0
	#--> set GPP demand to zeros
	# compute demand GPP with no stress. AllDemScGPP is set to ones in the prec; & hence the demand have no stress in GPP.
	gppE = fAPAR * gppPot * AllDemScGPP

	## pack variables
	@pack_land begin
		(AllDemScGPP, gppE) ∋ land.gppDemand
		scall ∋ land.states
	end
	return land
end

function compute(o::gppDemand_none, forcing, land, infotem)
	# @unpack_gppDemand_none o
	return land
end

function update(o::gppDemand_none, forcing, land, infotem)
	# @unpack_gppDemand_none o
	return land
end

"""
sets the scalar for demand GPP to ones & demand GPP to zeros. sets the scalar for demand GPP to ones & demand GPP to zeros

# precompute:
precompute/instantiate time-invariant variables for gppDemand_none

# compute:
Combine effects as multiplicative or minimum using gppDemand_none

*Inputs:*
 - info

*Outputs:*
 - land.gppDemand.AllDemScGPP: effective scalar of demands
 - land.gppDemand.gppE: demand-driven GPP with no stress

# update
update pools and states in gppDemand_none
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - Nuno Carvalhais [ncarval]
"""
function gppDemand_none_h end