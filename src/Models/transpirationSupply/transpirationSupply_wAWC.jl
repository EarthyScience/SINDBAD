export transpirationSupply_wAWC

#! format: off
@bounds @describe @units @with_kw struct transpirationSupply_wAWC{T1} <: transpirationSupply
    k_transpiration::T1 = 0.99 | (0.002, 1.0) | "fraction of total maximum available water that can be transpired" | ""
end
#! format: on

function compute(p_struct::transpirationSupply_wAWC, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationSupply_wAWC p_struct

    ## unpack land variables
    @unpack_land PAW ∈ land.states

    ## calculate variables
    transpiration_supply = sum(PAW) * k_transpiration

    ## pack land variables
    @pack_land transpiration_supply => land.transpirationSupply
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
 - land.soilWBase.wAWC: total maximum plant available water [FC-WP]
 - land.states.PAW: actual extractable water

*Outputs*
 - land.transpirationSupply.transpiration_supply: supply limited transpiration

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
