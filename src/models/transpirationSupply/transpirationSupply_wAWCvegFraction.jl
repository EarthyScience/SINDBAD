export transpirationSupply_wAWCvegFraction

@bounds @describe @units @with_kw struct transpirationSupply_wAWCvegFraction{T1} <: transpirationSupply
	tranFrac::T1 = 1.0 | (0.02, 1.0) | "fraction of total maximum available water that can be transpired" | ""
end

function compute(o::transpirationSupply_wAWCvegFraction, forcing, land, helpers)
	## unpack parameters
	@unpack_transpirationSupply_wAWCvegFraction o

	## unpack land variables
	@unpack_land (pawAct, vegFraction) ∈ land.states


	## calculate variables
	tranSup = sum(pawAct) * tranFrac * vegFraction

	## pack land variables
	@pack_land tranSup => land.transpirationSupply
	return land
end

@doc """
calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture; scaled by vegetated fractions

# Parameters
$(PARAMFIELDS)

---

# compute:
Supply-limited transpiration using transpirationSupply_wAWCvegFraction

*Inputs*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.pawAct: actual extractable water
 - land.states.vegFraction: vegetation fraction

*Outputs*
 - land.transpirationSupply.tranSup: supply limited transpiration
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - skoirala

*Notes*
 - Assumes that the transpiration supply scales with vegetated fraction
"""
transpirationSupply_wAWCvegFraction