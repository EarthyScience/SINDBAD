export transpirationSupply_Federer1982

#! format: off
@bounds @describe @units @with_kw struct transpirationSupply_Federer1982{T1} <: transpirationSupply
    maxRate::T1 = 5.0 | (0.1, 20.0) | "Maximum rate of transpiration in mm/day" | "mm/day"
end
#! format: on

function compute(p_struct::transpirationSupply_Federer1982, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationSupply_Federer1982 p_struct

    ## unpack land variables
    @unpack_land begin
        PAW ∈ land.states
        sum_wSat ∈ land.soilWBase
    end
    transpiration_supply = maxRate * sum(PAW) / sum_wSat

    ## pack land variables
    @pack_land transpiration_supply => land.states
    return land
end

@doc """
calculate the supply limited transpiration as a function of max rate parameter & avaialable water

# Parameters
$(SindbadParameters)

---

# compute:
Supply-limited transpiration using transpirationSupply_Federer1982

*Inputs*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.wAWC: total maximum plant available water [FC-WP]
 - land.states.PAW: actual extractable water

*Outputs*
 - land.states.transpiration_supply: demand driven transpiration

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
transpirationSupply_Federer1982
