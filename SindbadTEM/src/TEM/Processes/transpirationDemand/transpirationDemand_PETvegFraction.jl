export transpirationDemand_PETvegFraction

#! format: off
@bounds @describe @units @timescale @with_kw struct transpirationDemand_PETvegFraction{T1} <: transpirationDemand
    α::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | "" | ""
end
#! format: on

function compute(params::transpirationDemand_PETvegFraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationDemand_PETvegFraction params

    ## unpack land variables
    @unpack_nt begin
        frac_vegetation ⇐ land.states
        PET ⇐ land.fluxes
    end
    transpiration_demand = PET * α * frac_vegetation

    ## pack land variables
    @pack_nt transpiration_demand ⇒ land.diagnostics
    return land
end

purpose(::Type{transpirationDemand_PETvegFraction}) = "Demand-limited transpiration as a function of PET, a vegetation parameter, and vegetation fraction."

@doc """

$(getModelDocString(transpirationDemand_PETvegFraction))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko

*Notes*
 - Assumes that the transpiration demand scales with vegetated fraction
"""
transpirationDemand_PETvegFraction
