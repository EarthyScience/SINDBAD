export gppDemand_mult

struct gppDemand_mult <: gppDemand
end

function precompute(o::gppDemand_mult, forcing, land, helpers)


	## unpack land variables

	# set 3d scalar matrix with current scalars
	scall = SVector(helpers.numbers.sNT.(zeros(4))...)
	AllDemScGPP = helpers.numbers.𝟙
	gppE = helpers.numbers.𝟘
	@pack_land (scall,AllDemScGPP, gppE) => land.gppDemand

	return land
end

function compute(o::gppDemand_mult, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		CloudScGPP ∈ land.gppDiffRadiation
		fAPAR ∈ land.states
		gppPot ∈ land.gppPotential
		LightScGPP ∈ land.gppDirRadiation
		scall ∈ land.gppDemand
		TempScGPP ∈ land.gppAirT
		VPDScGPP ∈ land.gppVPD
	end

	# @show TempScGPP, VPDScGPP, scall
	# set 3d scalar matrix with current scalars
	scall = ups(scall, TempScGPP, scall, scall, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
	scall = ups(scall, VPDScGPP, scall, scall, helpers.numbers.𝟘, helpers.numbers.𝟙, 2)
	scall = ups(scall, LightScGPP, scall, scall, helpers.numbers.𝟘, helpers.numbers.𝟙, 3)
	scall = ups(scall, CloudScGPP, scall, scall, helpers.numbers.𝟘, helpers.numbers.𝟙, 4)

	# compute the product of all the scalars
	AllDemScGPP = prod(scall)
	
	# compute demand GPP
	gppE = fAPAR * gppPot * AllDemScGPP

	## pack land variables
	@pack_land (AllDemScGPP, gppE) => land.gppDemand
	return land
end

@doc """
compute the demand GPP as multipicative stress scalars

---

# compute:
Combine effects as multiplicative or minimum using gppDemand_mult

*Inputs*
 - land.gppAirT.TempScGPP: temperature effect on GPP [-], between 0-1
 - land.gppDiffRadiation.CloudScGPP: cloudiness scalar [-], between 0-1
 - land.gppDirRadiation.LightScGPP: light saturation scalar [-], between 0-1
 - land.gppPotential.gppPot: maximum potential GPP based on radiation use efficiency
 - land.gppVPD.VPDScGPP: VPD effect on GPP [-], between 0-1
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  [-] (equivalent to "canopy cover" in Gash & Miralles)

*Outputs*
 - land.gppDemand.AllDemScGPP [effective scalar, 0-1]
 - land.gppDemand.gppE: demand GPP [gC/m2/time]

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gppDemand_mult