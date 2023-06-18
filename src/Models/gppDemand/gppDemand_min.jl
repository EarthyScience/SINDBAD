export gppDemand_min

struct gppDemand_min <: gppDemand
end

function precompute(o::gppDemand_min, forcing, land, helpers)
	@unpack_land (𝟘, 𝟙, tolerance, numType, sNT) ∈ helpers.numbers

	scall = ones(numType, 4)

	if hasproperty(land.pools, :soilW)
		if typeof(land.pools.soilW)<:SVector{length(land.pools.soilW)}
			scall = SVector{4}(scall)
		end
	end

	AllDemScGPP = 𝟙
	gppE = 𝟘
	@pack_land (scall, AllDemScGPP, gppE) => land.gppDemand

	return land
end

function compute(o::gppDemand_min, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		CloudScGPP ∈ land.gppDiffRadiation
		fAPAR ∈ land.states
		gppPot ∈ land.gppPotential
		LightScGPP ∈ land.gppDirRadiation
		scall ∈ land.gppDemand
		TempScGPP ∈ land.gppAirT
        (𝟘, 𝟙) ∈ helpers.numbers
	end

	# @show TempScGPP, VPDScGPP, scall
	# set 3d scalar matrix with current scalars
	scall = rep_elem(scall, TempScGPP, scall, scall, 𝟘, 𝟙, 1)
	scall = rep_elem(scall, VPDScGPP, scall, scall, 𝟘, 𝟙, 2)
	scall = rep_elem(scall, LightScGPP, scall, scall, 𝟘, 𝟙, 3)
	scall = rep_elem(scall, CloudScGPP, scall, scall, 𝟘, 𝟙, 4)
	
	# compute the minumum of all the scalars
	AllDemScGPP = minimum(scall)
	
	# compute demand GPP
	gppE = fAPAR * gppPot * AllDemScGPP

	## pack land variables
	@pack_land (AllDemScGPP, gppE) => land.gppDemand
	return land
end

@doc """
compute the demand GPP as minimum of all stress scalars [most limited]

---

# compute:
Combine effects as multiplicative or minimum using gppDemand_min

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
gppDemand_min