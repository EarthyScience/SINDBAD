export transpirationDemand_PET

#! format: off
@bounds @describe @units @timescale @with_kw struct transpirationDemand_PET{T1} <: transpirationDemand
    α::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | "" | ""
end
#! format: on

function compute(params::transpirationDemand_PET, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationDemand_PET params

    ## unpack land variables
    @unpack_nt PET ⇐ land.fluxes

    ## calculate variables
    transpiration_demand = PET * α

    ## pack land variables
    @pack_nt transpiration_demand ⇒ land.diagnostics
    return land
end

purpose(::Type{transpirationDemand_PET}) = "calculate the climate driven demand for transpiration as a function of PET & α for vegetation"

@doc """

$(getBaseDocString(transpirationDemand_PET))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by*
 - skoirala
"""
transpirationDemand_PET
