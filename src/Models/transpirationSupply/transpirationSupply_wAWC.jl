export transpirationSupply_wAWC

@bounds @describe @units @with_kw struct transpirationSupply_wAWC{T1} <: transpirationSupply
	tranFrac::T1 = 0.9 | (0.02, 0.98) | "fraction of total maximum available water that can be transpired" | ""
end

function compute(o::transpirationSupply_wAWC, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_transpirationSupply_wAWC o

	## unpack land variables
	@unpack_land PAW ∈ land.vegAvailableWater

	## calculate variables
	tranSup = sum(PAW) * tranFrac

	## pack land variables
	@pack_land tranSup => land.transpirationSupply
	return land
end

@doc """
calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture

# Parameters
$(PARAMFIELDS)

---

# compute:
Supply-limited transpiration using transpirationSupply_wAWC

*Inputs*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.PAW: actual extractable water

*Outputs*
 - land.transpirationSupply.tranSup: supply limited transpiration

---

# Extended help

*References*
 - Teuling; 2007 | 2009: Time scales.#

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
transpirationSupply_wAWC