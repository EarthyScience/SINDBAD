export transpirationSupply_wAWC

#! format: off
@bounds @describe @units @timescale @with_kw struct transpirationSupply_wAWC{T1} <: transpirationSupply
    k_transpiration::T1 = 0.99 | (0.002, 1.0) | "fraction of total maximum available water that can be transpired" | "" | ""
end
#! format: on

function compute(params::transpirationSupply_wAWC, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationSupply_wAWC params

    ## unpack land variables
    @unpack_nt PAW ⇐ land.states

    ## calculate variables
    transpiration_supply = sum(PAW) * k_transpiration

    ## pack land variables
    @pack_nt transpiration_supply ⇒ land.diagnostics
    return land
end

purpose(::Type{transpirationSupply_wAWC}) = "calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture"

@doc """

$(getBaseDocString(transpirationSupply_wAWC))

---

# Extended help

*References*
 - Teuling; 2007 | 2009: Time scales.#

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by*
 - skoirala
"""
transpirationSupply_wAWC
