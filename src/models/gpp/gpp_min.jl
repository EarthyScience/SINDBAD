export gpp_min

struct gpp_min <: gpp
end

function compute(o::gpp_min, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		AllDemScGPP ∈ land.gppDemand
		fAPAR ∈ land.states
		gppPot ∈ land.gppPotential
		SMScGPP ∈ land.gppSoilW
	end

	AllScGPP = min(AllDemScGPP, SMScGPP)
	# & multiply
	gpp = fAPAR * gppPot * AllScGPP

	## pack land variables
	@pack_land begin
		gpp => land.fluxes
		AllScGPP => land.gpp
	end
	return land
end

@doc """
compute the actual GPP with potential scaled by minimum stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration]

---

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_min

*Inputs*
 - land.gppDemand.AllDemScGPP: effective demand scalars; between 0-1
 - land.gppPotential.gppPot: maximum potential GPP based on radiation use efficiency
 - land.gppSoilW.SMScGPP: soil moisture stress scalar; between 0-1
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  [-] (equivalent to "canopy cover" in Gash & Miralles)

*Outputs*
 - land.fluxes.gpp: actual GPP [gC/m2/time]
 - land.gpp.AllScGPP

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gpp_min