export gppDemand_none

struct gppDemand_none <: gppDemand
end

function precompute(o::gppDemand_none, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_land begin
		fAPAR ∈ land.states
		gppPot ∈ land.gppPotential
	end

	## calculate variables
	# set scalar to a constant one [no effect on potential GPP]
	AllDemScGPP = helpers.numbers.𝟙

	# compute demand GPP with no stress. AllDemScGPP is set to ones in the prec; & hence the demand have no stress in GPP.
	gppE = fAPAR * gppPot * AllDemScGPP

	## pack land variables
	@pack_land (AllDemScGPP, gppE) => land.gppDemand
	return land
end

@doc """
sets the scalar for demand GPP to ones & demand GPP to zero

---

# compute:
Combine effects as multiplicative or minimum using gppDemand_none

*Inputs*
 - helpers

*Outputs*
 - land.gppDemand.AllDemScGPP: effective scalar of demands
 - land.gppDemand.gppE: demand-driven GPP with no stress

# precompute:
precompute/instantiate time-invariant variables for gppDemand_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - ncarval
"""
gppDemand_none