export transpirationSupply_wAWCvegFraction

#! format: off
@bounds @describe @units @timescale @with_kw struct transpirationSupply_wAWCvegFraction{T1} <: transpirationSupply
    k_transpiration::T1 = 1.0 | (0.02, 1.0) | "fraction of total maximum available water that can be transpired" | "" | ""
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

purpose(::Type{transpirationSupply_wAWCvegFraction}) = "calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture; scaled by vegetated fractions"

@doc """

$(getBaseDocString(fraction))

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
