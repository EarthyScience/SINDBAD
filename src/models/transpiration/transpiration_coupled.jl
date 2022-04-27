export transpiration_coupled

struct transpiration_coupled <: transpiration
end

function compute(o::transpiration_coupled, forcing, land::NamedTuple, helpers::NamedTuple)

	## unpack land variables
	@unpack_land begin
		gpp ∈ land.fluxes
		AoE ∈ land.WUE
	end
	# calculate actual transpiration coupled with GPP
	transpiration = gpp / AoE

	## pack land variables
	@pack_land transpiration => land.fluxes
	return land
end

@doc """
calculate the actual transpiration as function of gppAct & WUE

---

# compute:
If coupled, computed from gpp and aoe from wue using transpiration_coupled

*Inputs*
 - land.WUE.AoE: water use efficiency in gC/mmH2O
 - land.fluxes.gppAct: GPP based on a minimum of demand & stressors (except water  limitation) out of gppAct_coupled in which tranSup is used to get  supply limited GPP

*Outputs*
 - land.fluxes.transpiration: actual transpiration

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
transpiration_coupled