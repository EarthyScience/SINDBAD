export gpp_coupled

struct gpp_coupled <: gpp
end

function compute(o::gpp_coupled, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		tranSup ∈ land.transpirationSupply
		SMScGPP ∈ land.gppSoilW
		gppE ∈ land.gppDemand
		AoE ∈ land.WUE
		𝟙 ∈ helpers.numbers
	end
	
	gpp = min(𝟙 * tranSup * AoE, gppE * SMScGPP)
	# gpp = min(𝟙 * tranSup * AoE, gppE * soilWStress[2])
	# gpp = min(𝟙 * tranSup * AoE, gppE * max(soilWStress, [], 2))

	## pack land variables
	@pack_land gpp => land.fluxes
	return land
end

@doc """
calculate GPP based on transpiration supply & water use efficiency [coupled]

---

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_coupled

*Inputs*
 - land.WUE.AoE: water use efficiency in gC/mmH2O
 - land.gppDemand.gppE: Demand-driven GPP with stressors except soilW applied
 - land.gppSoilW.SMScGPP: soil moisture stress on photosynthetic capacity
 - land.transpirationSupply.tranSup: supply limited transpiration

*Outputs*
 - land.fluxes.gpp: actual GPP [gC/m2/time]

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - mjung
 - skoirala

*Notes*
"""
gpp_coupled