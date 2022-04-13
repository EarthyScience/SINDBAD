export gppDemand_min, gppDemand_min_h
"""
compute the demand GPP as minimum of all stress scalars [most limited]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppDemand_min{T} <: gppDemand
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gppDemand_min, forcing, land, infotem)
	# @unpack_gppDemand_min o
	return land
end

function compute(o::gppDemand_min, forcing, land, infotem)
	@unpack_gppDemand_min o

	## unpack variables
	@unpack_land begin
		fAPAR ∈ land.states
		VPDScGPP ∈ land.gppVPD
		gppPot ∈ land.gppPotential
		LightScGPP ∈ land.gppDirRadiation
		CloudScGPP ∈ land.gppDiffRadiation
		TempScGPP ∈ land.gppAirT
	end
	scall = repeat([1.0], 1, 4)
	# set 3d scalar matrix with current scalars
	scall[1] = TempScGPP
	scall[2] = VPDScGPP
	scall[3] = LightScGPP
	scall[4] = CloudScGPP
	# compute the minumum of all the scalars
	AllDemScGPP = minimum(scall)
	# compute demand GPP
	gppE = fAPAR * gppPot * AllDemScGPP

	## pack variables
	@pack_land begin
		(AllDemScGPP, gppE) ∋ land.gppDemand
		scall ∋ land.states
	end
	return land
end

function update(o::gppDemand_min, forcing, land, infotem)
	# @unpack_gppDemand_min o
	return land
end

"""
compute the demand GPP as minimum of all stress scalars [most limited]

# precompute:
precompute/instantiate time-invariant variables for gppDemand_min

# compute:
Combine effects as multiplicative or minimum using gppDemand_min

*Inputs:*
 - land.gppAirT.TempScGPP: temperature effect on GPP [-], between 0-1
 - land.gppDiffRadiation.CloudScGPP: cloudiness scalar [-], between 0-1
 - land.gppDirRadiation.LightScGPP: light saturation scalar [-], between 0-1
 - land.gppPotential.gppPot: maximum potential GPP based on radiation use efficiency
 - land.gppVPD.VPDScGPP: VPD effect on GPP [-], between 0-1
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  [-] (equivalent to "canopy cover" in Gash & Miralles)

*Outputs:*
 - land.gppDemand.AllDemScGPP [effective scalar, 0-1]
 - land.gppDemand.gppE: demand GPP [gC/m2/time]

# update
update pools and states in gppDemand_min
 - land.states.scall

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]

*Notes:*
"""
function gppDemand_min_h end