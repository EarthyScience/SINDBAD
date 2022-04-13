export gppDiffRadiation_Turner2006, gppDiffRadiation_Turner2006_h
"""
calculate the cloudiness scalar [radiation diffusion] on gppPot

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppDiffRadiation_Turner2006{T1} <: gppDiffRadiation
	rueRatio::T1 = 0.5 | (0.0001, 1.0) | "ratio of clear sky LUE to max LUE" | ""
end

function precompute(o::gppDiffRadiation_Turner2006, forcing, land, infotem)
	# @unpack_gppDiffRadiation_Turner2006 o
	return land
end

function compute(o::gppDiffRadiation_Turner2006, forcing, land, infotem)
	@unpack_gppDiffRadiation_Turner2006 o

	## unpack variables
	@unpack_land begin
		(Rg, RgPot) ∈ forcing
	end
	CI = 0.0
	valid = RgPot > 0.0;
	CI[valid] = Rg[valid] / RgPot[valid]
	SCI = (CI - minimum(CI, 2)) / (maximum(CI, 2) - minimum(CI, 2))
	CloudScGPP = (1.0 - rueRatio) * SCI + rueRatio

	## pack variables
	@pack_land begin
		CloudScGPP ∋ land.gppDiffRadiation
	end
	return land
end

function update(o::gppDiffRadiation_Turner2006, forcing, land, infotem)
	# @unpack_gppDiffRadiation_Turner2006 o
	return land
end

"""
calculate the cloudiness scalar [radiation diffusion] on gppPot

# precompute:
precompute/instantiate time-invariant variables for gppDiffRadiation_Turner2006

# compute:
Effect of diffuse radiation using gppDiffRadiation_Turner2006

*Inputs:*
 - forcing.Rg: Global radiation [SW incoming] [MJ/m2/time]
 - forcing.RgPot: Potential radiation [MJ/m2/time]

*Outputs:*
 - land.gppDiffRadiation.CloudScGPP: effect of cloudiness on potential GPP

# update
update pools and states in gppDiffRadiation_Turner2006
 -

# Extended help

*References:*
 - Turner, D. P., Ritts, W. D., Styles, J. M., Yang, Z., Cohen, W. B., Law, B. E., & Thornton, P. E. (2006).  A diagnostic carbon flux model to monitor the effects of disturbance & interannual variation in  climate on regional NEP. Tellus B: Chemical & Physical Meteorology, 58[5], 476-490.  DOI: 10.1111/j.1600-0889.2006.00221.x

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - Martin Jung [mjung]
 - Nuno Carvalhais [ncarval]
"""
function gppDiffRadiation_Turner2006_h end