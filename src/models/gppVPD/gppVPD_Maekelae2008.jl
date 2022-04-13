export gppVPD_Maekelae2008, gppVPD_Maekelae2008_h
"""
calculate the VPD stress on gppPot based on Maekelae2008 [eqn 5]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppVPD_Maekelae2008{T1} <: gppVPD
	k::T1 = 0.4 | (0.06, 0.7) | "empirical parameter assuming typically negative values" | "kPa-1"
end

function precompute(o::gppVPD_Maekelae2008, forcing, land, infotem)
	# @unpack_gppVPD_Maekelae2008 o
	return land
end

function compute(o::gppVPD_Maekelae2008, forcing, land, infotem)
	@unpack_gppVPD_Maekelae2008 o

	## unpack variables
	@unpack_land begin
		VPDDay ∈ forcing
	end
	pk = k
	VPDScGPP = exp(-pk * VPDDay)
	VPDScGPP[VPDScGPP > 1] = 1

	## pack variables
	@pack_land begin
		VPDScGPP ∋ land.gppVPD
	end
	return land
end

function update(o::gppVPD_Maekelae2008, forcing, land, infotem)
	# @unpack_gppVPD_Maekelae2008 o
	return land
end

"""
calculate the VPD stress on gppPot based on Maekelae2008 [eqn 5]

# precompute:
precompute/instantiate time-invariant variables for gppVPD_Maekelae2008

# compute:
Vpd effect using gppVPD_Maekelae2008

*Inputs:*

*Outputs:*
 - land.gppVPD.VPDScGPP: VPD effect on GPP [] dimensionless, between 0-1

# update
update pools and states in gppVPD_Maekelae2008
 -

# Extended help

*References:*

*Versions:*

*Created by:*
 - Nuno Carvalhais [ncarval]

*Notes:*
 - Equation 5. a negative exponent is introduced to have positive parameter  values
"""
function gppVPD_Maekelae2008_h end