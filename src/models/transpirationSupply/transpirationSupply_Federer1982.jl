export transpirationSupply_Federer1982

@bounds @describe @units @with_kw struct transpirationSupply_Federer1982{T1} <: transpirationSupply
	maxRate::T1 = 5.0 | (0.1, 20.0) | "Maximum rate of transpiration in mm/day" | "mm/day"
end

function compute(o::transpirationSupply_Federer1982, forcing, land, infotem)
	## unpack parameters
	@unpack_transpirationSupply_Federer1982 o

	## unpack land variables
	@unpack_land begin
		pawAct ∈ land.states
		p_wSat ∈ land.soilWBase
	end
	tranSup = maxRate * sum(pawAct) / sum(p_wSat)

	## pack land variables
	@pack_land tranSup => land.transpirationSupply
	return land
end

@doc """
calculate the supply limited transpiration as a function of max rate parameter & avaialable water

# Parameters
$(PARAMFIELDS)

---

# compute:
Supply-limited transpiration using transpirationSupply_Federer1982

*Inputs*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.pawAct: actual extractable water

*Outputs*
 - land.transpirationSupply.tranSup: demand driven transpiration
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
transpirationSupply_Federer1982