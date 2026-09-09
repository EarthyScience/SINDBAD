export cMicrobialEfficiency_CASApool

#! format: off
@bounds @describe @units @timescale @with_kw struct cMicrobialEfficiency_CASApool{T1,T2} <: cMicrobialEfficiency
    effA::T1 = 0.85 | (0.0, 1.0) | "Intercept of the linear of microbial carbon-transfer efficiency to soil texture." | "" | ""
    effB::T2 = 0.68 | (0.0, Inf) | "Sensitivity of microbial carbon-transfer efficiency to soil texture (silt+clay fraction)." | "" | ""
end
#! format: on

function precompute(params::cMicrobialEfficiency_CASApool, forcing, land, helpers)
    ## unpack parameters
    @unpack_cMicrobialEfficiency_CASApool params

    ## unpack land variables
    @unpack_nt begin
        c_flow_ME_vec ⇐ land.diagnostics
        c_flow_named_edges ⇐ land.cCycleBase
        (st_clay, st_silt) ⇐ land.properties
    end

    ## calculate variables
    # The 14 statically-known CASA transfers already carry their default efficiency
    # from CASA_FLOW_EDGES, so only the texture-driven pair is computed here.
    microbial_efficiency = meTextureEfficiency(effA, effB, st_clay, st_silt)
    for edge ∈ (:cMicSoil_to_cSoilSlow, :cMicSoil_to_cSoilOld)
        c_flow_ME_vec = setMEFlow(c_flow_ME_vec, c_flow_named_edges, edge, microbial_efficiency)
    end

    ## pack land variables
    @pack_nt c_flow_ME_vec ⇒ land.diagnostics
    return land
end

purpose(::Type{cMicrobialEfficiency_CASApool}) = "CASA microbial carbon-transfer efficiency built on the pool configuration's own defaults, adding only the soil-texture response of the two microbial-to-soil transfers."

@doc """

	$(getModelDocString(cMicrobialEfficiency_CASApool))

---
# Extended help

The 14 statically-known transfers of the CASA table (litter decomposition, surface
microbial turnover, and the soil group) are not restated here: `CASA_FLOW_EDGES`
already carries them as the CASA pool definition's own microbial-efficiency defaults,
so `c_flow_ME_vec` starts at those values before this approach, or any
`cMicrobialEfficiency` approach, ever runs. This approach only adds the one pathway
the pool declaration cannot give a real value to: the soil microbial pool's texture
response, written into `cMicSoil_to_cSoilSlow` and `cMicSoil_to_cSoilOld`.

This is the pool-config-based counterpart of [`cMicrobialEfficiency_CASA`](@ref), which
restates the whole table from its own parameters regardless of what the pool
configuration already put in `c_flow_ME_vec`. Selecting either on `CarbonPoolsCASA`
produces the same `c_flow_ME_vec`, by different routes; the two exist side by side so
that can be checked. Selecting neither, on CASA pools, already leaves the 14 static
defaults in place and a static `0.45` fallback on the two texture-driven transfers,
rather than the neutral efficiency of one that every other pool structure keeps
without a `cMicrobialEfficiency` approach.

*References*
 - Carvalhais, N., Reichstein, M., Seixas, J., Collatz, G. J., Pereira, J. S., Berbigier, P., & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for biogeochemical modeling performance and inverse parameter retrieval. Global Biogeochemical Cycles, 22(2).
 - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.

*Versions*
 - 1.0 on 09.09.2026 [skoirala]

*Created by*
 - skoirala

"""
cMicrobialEfficiency_CASApool
