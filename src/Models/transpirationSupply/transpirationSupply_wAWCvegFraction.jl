export transpirationSupply_wAWCvegFraction

#! format: off
@bounds @describe @units @with_kw struct transpirationSupply_wAWCvegFraction{T1} <: transpirationSupply
    k_transpiration::T1 = 1.0 | (0.02, 1.0) | "fraction of total maximum available water that can be transpired" | ""
end
#! format: on

function compute(params::transpirationSupply_wAWCvegFraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationSupply_wAWCvegFraction params

    ## unpack land variables
    @unpack_nt (PAW, frac_vegetation) ⇐ land.states

    ## calculate variables
    transpiration_supply = sum(PAW) * k_transpiration * frac_vegetation

    ## pack land variables
    @pack_nt transpiration_supply ⇒ land.diagnostics
    return land
end

@doc """
calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture; scaled by vegetated fractions

# Parameters
$(SindbadParameters)

---

# compute:
Supply-limited transpiration using transpirationSupply_wAWCvegFraction

*Inputs*
 - land.pools.soilW : total soil moisture
 - land.properties.w_awc: total maximum plant available water [_fc-_wp]
 - land.states.PAW: actual extractable water
 - land.states.frac_vegetation: vegetation fraction

*Outputs*
 - land.states.transpiration_supply: supply limited transpiration

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
