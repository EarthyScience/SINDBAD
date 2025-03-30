export transpiration_demandSupply

struct transpiration_demandSupply <: transpiration end

function compute(params::transpiration_demandSupply, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        transpiration_supply ⇐ land.diagnostics
        transpiration_demand ⇐ land.diagnostics
    end

    transpiration = min(transpiration_demand, transpiration_supply)

    ## pack land variables
    @pack_nt transpiration ⇒ land.fluxes
    return land
end

purpose(::Type{transpiration_demandSupply}) = "calculate the actual transpiration as the minimum of the supply & demand"

@doc """

$(getBaseDocString(transpiration_demandSupply))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by*
 - skoirala

*Notes*
 - ignores biological limitation of transpiration demand
"""
transpiration_demandSupply
