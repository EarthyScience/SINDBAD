export transpirationDemand_PETfAPAR

#! format: off
@bounds @describe @units @timescale @with_kw struct transpirationDemand_PETfAPAR{T1} <: transpirationDemand
    α::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | "" | ""
end
#! format: on

function compute(params::transpirationDemand_PETfAPAR, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationDemand_PETfAPAR params

    ## unpack land variables
    @unpack_nt begin
        fAPAR ⇐ land.states
        PET ⇐ land.fluxes
    end
    transpiration_demand = PET * α * fAPAR

    ## pack land variables
    @pack_nt transpiration_demand ⇒ land.diagnostics
    return land
end

purpose(::Type{transpirationDemand_PETfAPAR}) = "calculate the climate driven demand for transpiration as a function of PET & fAPAR"

@doc """

$(getModelDocString(transpirationDemand_PETfAPAR))

---

# Extended help

*References*

*Versions*
 - 1.0 on 30.04.2020 [skoirala | @dr-ko]

*Created by*
 - sbesnard; skoirala; ncarvalhais

*Notes*
 - Assumes that the transpiration demand scales with vegetated fraction
"""
transpirationDemand_PETfAPAR
