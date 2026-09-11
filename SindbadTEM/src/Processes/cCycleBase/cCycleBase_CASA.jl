export cCycleBase_CASA
export meCASAFlowsLitter
export meCASAFlowsSoil

"""
    meCASAFlowsLitter(eff_cLit_to_cMicSurf, eff_cLitRootFine_to_cMicSoil,
        eff_cLitRootCoarse_to_cMicSoil, eff_cLit_to_cSoilSlow,
        eff_cLitRootFine_to_cSoilSlow)

The CASA microbial carbon-transfer efficiency of every litter decomposition pathway, as
`edge => value` pairs keyed by giver-to-taker pool-name pair.

The surface microbial pathway retains least, the direct route into slow soil most, and
fine roots sit between the two because they decompose in the soil rather than at the
surface. The last two entries are the aggregated GSI litter pools, which take the
litter-to-soil efficiency; on CASA they are absent and `setMEFlow` skips them, and on GSI
the CASA-only entries are absent instead, so one table serves both.

Declared as a function, called from `precompute` below to seed `c_flow_ME_vec` with
CASA's static litter defaults. Lives here, alongside the approach that is its only
caller, rather than in `cMicrobialEfficiencycLit` (a sibling process whose own
`_texture`/`_none`/`_constant` approaches this table has nothing to do with) -- moved
here from there since a plain helper function has no reason to live in a different
process's namespace than the one approach that calls it. This is the assignment whose
`cLitRootCoarse` and `cLitWood` columns were transposed for as long as it was a dense
array indexed by position, so it is kept as one table read from one place rather than
written inline.
"""
function meCASAFlowsLitter(eff_cLit_to_cMicSurf, eff_cLitRootFine_to_cMicSoil,
        eff_cLitRootCoarse_to_cMicSoil, eff_cLit_to_cSoilSlow,
        eff_cLitRootFine_to_cSoilSlow)
    return (
        (:cLitLeafFast_to_cMicSurf, eff_cLit_to_cMicSurf),
        (:cLitLeafSlow_to_cMicSurf, eff_cLit_to_cMicSurf),
        (:cLitWood_to_cMicSurf, eff_cLit_to_cMicSurf),
        (:cLitRootFineFast_to_cMicSoil, eff_cLitRootFine_to_cMicSoil),
        (:cLitRootFineSlow_to_cMicSoil, eff_cLitRootFine_to_cMicSoil),
        (:cLitRootCoarse_to_cMicSoil, eff_cLitRootCoarse_to_cMicSoil),
        (:cLitLeafSlow_to_cSoilSlow, eff_cLit_to_cSoilSlow),
        (:cLitRootCoarse_to_cSoilSlow, eff_cLit_to_cSoilSlow),
        (:cLitWood_to_cSoilSlow, eff_cLit_to_cSoilSlow),
        (:cLitRootFineSlow_to_cSoilSlow, eff_cLitRootFine_to_cSoilSlow),
        (:cLitFast_to_cSoilSlow, eff_cLit_to_cSoilSlow),
        (:cLitSlow_to_cSoilSlow, eff_cLit_to_cSoilSlow),
    )
end

"""
    meCASAFlowsSoil(eff_cSoil_to_cMicSoil, eff_cSoilSlow_to_cSoilOld)

The CASA microbial carbon-transfer efficiency of the soil decomposition pathways, as
`edge => value` pairs keyed by giver-to-taker pool-name pair.

The two routes carry the same CASA value but are separate parameters so that
stabilization into old soil carbon and the return to the microbial pool can be calibrated
apart. On the GSI structures only `cSoilSlow_to_cSoilOld` exists and the other two are
skipped.

Declared as a function, called from `precompute` below to seed `c_flow_ME_vec` with
CASA's static soil defaults, for the same reason `meCASAFlowsLitter` lives here rather
than in `cMicrobialEfficiencycSoil`: it belongs beside its only caller, not in a
different process's namespace.
"""
function meCASAFlowsSoil(eff_cSoil_to_cMicSoil, eff_cSoilSlow_to_cSoilOld)
    return (
        (:cSoilSlow_to_cMicSoil, eff_cSoil_to_cMicSoil),
        (:cSoilOld_to_cMicSoil, eff_cSoil_to_cMicSoil),
        (:cSoilSlow_to_cSoilOld, eff_cSoilSlow_to_cSoilOld),
    )
end

#! format: off
@bounds @describe @units @timescale @with_kw struct cCycleBase_CASA{T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15} <: cCycleBase
    k_c_scalar::T1 = 1.0 | (0.25, 4.0) | "scalar for the per-pool turnover rate of ecosystem carbon pools" | "-" | "year"
    rootfine_age_scalar::T2 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT mean age of fine roots" | "-" | ""
    rootcoarse_age_scalar::T3 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT mean age of coarse roots" | "-" | ""
    wood_age_scalar::T4 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT mean age of wood" | "-" | ""
    leaf_age_scalar::T5 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT mean age of leaves" | "-" | ""
    CN_ratio_scalar::T6 = 1.0 | (0.25, 4.0) | "scalar for the vegetation carbon-to-nitrogen ratio" | "-" | ""
    eff_cLit_to_cMicSurf::T7 = 0.4 | (0.0, 1.0) | "Microbial carbon-transfer efficiency of litter decomposition into the surface microbial pool." | "fraction" | ""
    eff_cLitRootFine_to_cMicSoil::T8 = 0.45 | (0.0, 1.0) | "Microbial carbon-transfer efficiency of fine-root litter decomposition into the soil microbial pool." | "fraction" | ""
    eff_cLitRootCoarse_to_cMicSoil::T9 = 0.4 | (0.0, 1.0) | "Microbial carbon-transfer efficiency of coarse-root litter decomposition into the soil microbial pool." | "fraction" | ""
    eff_cLit_to_cSoilSlow::T10 = 0.6 | (0.0, 1.0) | "Microbial carbon-transfer efficiency of structural and woody litter decomposition into the slow soil pool." | "fraction" | ""
    eff_cLitRootFine_to_cSoilSlow::T11 = 0.55 | (0.0, 1.0) | "Microbial carbon-transfer efficiency of fine-root structural litter decomposition into the slow soil pool." | "fraction" | ""
    eff_cMicSurf_to_cSoilSlow::T12 = 0.4 | (0.0, 1.0) | "Microbial carbon-transfer efficiency of surface microbial turnover into the slow soil pool." | "fraction" | ""
    eff_cSoil_to_cMicSoil::T13 = 0.45 | (0.0, 1.0) | "Microbial carbon-transfer efficiency of slow and old soil decomposition returning to the soil microbial pool." | "fraction" | ""
    eff_cSoilSlow_to_cSoilOld::T14 = 0.45 | (0.0, 1.0) | "Microbial carbon-transfer efficiency of slow soil decomposition stabilized into old soil carbon." | "fraction" | ""
    c_remain::T15 = 50.0 | (0.1, 100.0) | "remaining carbon after disturbance" | "gC/m2" | ""
end
#! format: on

function define(params::cCycleBase_CASA, forcing, land, helpers)
    @unpack_cCycleBase_CASA params

    @unpack_nt begin
        cEco ⇐ land.pools
    end

    # one flow per declared edge of this approach, resolved against the configured
    # pool structure, rather than a transfer matrix carried as a parameter. The same
    # call keys the flows by pool-name pair and sizes the neutral flow vector, so a
    # cFlow approach reads the topology and fills in values instead of rederiving both
    (c_flow_order, c_taker, c_giver, c_flow_named_edges, c_flow_A_vec, c_flow_QP_vec,
        c_flow_ME_vec) = cFlowStructure(params, cEco, helpers)

    ## Instantiate variables, matching cCycleBase_GSI_PlantForm.jl: define only
    ## sets up structure (topology, zero-initialized arrays) and runs once ever,
    ## never on later parameter realizations, so nothing here may depend on an
    ## actual parameter value -- that happens in precompute instead.
    C_to_N_cVeg = zero(cEco)
    c_eco_k_base = zero(cEco)

    c_model = params

    ## pack land variables
    @pack_nt begin
        (C_to_N_cVeg, c_eco_k_base, c_flow_A_vec, c_flow_QP_vec, c_flow_ME_vec) ⇒ land.diagnostics
        (c_flow_order, c_taker, c_giver, c_flow_named_edges) ⇒ land.cCycleBase
        c_model ⇒ land.models
    end
    return land
end

function precompute(params::cCycleBase_CASA, forcing, land, helpers)
    ## unpack parameters
    @unpack_cCycleBase_CASA params

    ## unpack land variables
    @unpack_nt begin
        C_to_N_cVeg ⇐ land.diagnostics
        c_eco_k_base ⇐ land.diagnostics
        c_flow_ME_vec ⇐ land.diagnostics
        c_flow_named_edges ⇐ land.cCycleBase
    end

    ## calculate variables
    # CASA's own static microbial-efficiency table, applied on top of the
    # neutral c_flow_ME_vec define allocated. Lives here, not in define, since
    # the eff_* fields are ordinary optimizable parameters: precompute runs
    # once per parameter realization, so a value the optimizer changes is
    # picked up on the next iteration, unlike define which runs once ever. The
    # two soil-microbial edges this does not cover keep the neutral default
    # unless a texture-driven approach is selected (cMicrobialEfficiencycMic_texture,
    # or the per-group _CASA trio for the exact CASA distinction between the
    # surface and soil microbial pathways).
    ME_flows = (
        meCASAFlowsLitter(eff_cLit_to_cMicSurf, eff_cLitRootFine_to_cMicSoil,
            eff_cLitRootCoarse_to_cMicSoil, eff_cLit_to_cSoilSlow,
            eff_cLitRootFine_to_cSoilSlow)...,
        (:cMicSurf_to_cSoilSlow, eff_cMicSurf_to_cSoilSlow),
        meCASAFlowsSoil(eff_cSoil_to_cMicSoil, eff_cSoilSlow_to_cSoilOld)...,
    )
    for (edge, value) ∈ ME_flows
        c_flow_ME_vec = setMEFlow(c_flow_ME_vec, c_flow_named_edges, edge, value)
    end

    # carbon to nitrogen ratio [gC.gN-1] and turnover rate, both by pool name rather
    # than by cEco position, so a structure that ordered pools differently still gets
    # both in the right slots -- same convention cCycleBase_GSI_PlantForm.jl uses.
    # Bulk tuple-indexed broadcasting assignment is not supported on the land array
    # types used here (land.diagnostics arrays are immutable SVectors); every
    # GSI-family cCycleBase carries that exact note for the same reason, replaced by
    # applyPoolTable/applyPoolCNTable, their own functions rather than inline loops
    # here so Julia can infer this function's return type concretely (see
    # applyPoolTable's docstring, poolConfigurations/poolConfigurations.jl).
    C_to_N_cVeg = applyPoolCNTable(C_to_N_cVeg, CASA_CN_ratio, CN_ratio_scalar, helpers)
    c_eco_k_base = applyPoolTable(c_eco_k_base, CASA_TAU, k_c_scalar, helpers)

    ## pack land variables
    @pack_nt begin
        (C_to_N_cVeg, c_eco_k_base, c_flow_ME_vec) ⇒ land.diagnostics
        c_remain ⇒ land.states
    end
    return land
end

poolConfiguration(::Type{<:cCycleBase_CASA}) = CarbonPoolsCASA
cFlowEdges(::Type{<:cCycleBase_CASA}) = CASA_FLOW_EDGES
purpose(::Type{cCycleBase_CASA}) = "Structure and properties of the carbon cycle components used in the CASA approach."

@doc """

$(getModelDocString(cCycleBase_CASA))

---

# Extended help

# Pool topology

The 22 giver-to-taker links of this approach are declared as `CASA_FLOW_EDGES` in
`poolConfigurations/CASA.jl`, and the pools they name as
`poolStructure(CarbonPoolsCASA)` beside it. `cFlowMatrix(cCycleBase_CASA, pool_names)`
returns them as a `[taker, giver]` matrix of flow indices, and `plotCarbonFlows`
draws them, so neither has to be transcribed here to be read.

# Microbial efficiency

`precompute` also carries CASA's static microbial-carbon-transfer-efficiency table
as ordinary bounded parameters (`eff_cLit_to_cMicSurf` and the other seven), and
writes them into `c_flow_ME_vec` itself, so CASA has a realistic default even with
no `cMicrobialEfficiency` approach selected. Only the soil-microbial pool's texture
response is left out, since it needs `st_clay`/`st_silt` at runtime: select
`cMicrobialEfficiencycMic_texture` (composed with `_texture` for the other two groups
through `cMicrobialEfficiency_mult`) for it, applied to every transfer leaving a
microbial pool rather than singling out the soil one the way CASA's original table
did. This lives in `precompute`, not `define`, since the `eff_*` fields are
ordinary optimizable parameters: `define` runs once ever, so a value the optimizer
changes would never be picked up there.

# Turnover rate and carbon-to-nitrogen ratio

Likewise, `k_c_scalar`, `CN_ratio_scalar`, and the four `*_age_scalar` fields
are resolved in `precompute`, following the same pattern
`cCycleBase_GSI_PlantForm.jl` uses: `define` only allocates the zero-initialized
`c_eco_k_base`/`C_to_N_cVeg` arrays and the flow topology, and `precompute` writes
their actual values by pool name via `@rep_elem`, since the land arrays involved are
immutable `SVector`s that bulk `.=`/tuple-indexed assignment cannot mutate in place.
`CASA_TAU`/`CASA_CN_ratio` (in `poolConfigurations/CASA.jl`) carry the fixed per-pool
turnover-time and C:N-ratio data this file used to hold inline (as `CASA_ANNK`, a
rate rather than a time, and a 4-element `p_C_to_N_cVeg` vector read only for `cVeg`
pools); only `k_c_scalar`/`CN_ratio_scalar` are optimizable, since array-valued
struct fields are excluded from optimization entirely.

`k_c_scalar` declares `"year"` as its timescale, not `CASA_TAU` itself (a plain
`const`, outside the parameter-metadata system that timescale conversion keys
off). `getTypedModel`/`getParameters` (`SindbadTEM/src/Utils.jl`,
`src/Setup/setupParameters.jl`) rescale any `"year"`-timescale field's default and
bounds to the model's actual configured timestep before a run starts -- e.g. a
`k_c_scalar` default of `1.0` becomes `1/365` for a daily model -- so
`turnover_time` in `CASA_TAU` can stay expressed in years while `(1.0/
turnover_time) * k_c_scalar` still comes out already correctly scaled to the
model's own timestep. This was not the case for `annk_scalar`
(`cCycleBase_CASA_Legacy`, also `""` timescale) or `CASA_ANNK` before it existed as
a table at all: a genuine pre-existing bug, not something today's centralization
introduced, just never exercised end to end (see 1.4's note that this file "had
never actually been run end to end").

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 28.05.2022 [skoirala | @dr-ko]: migrate to julia
 - 1.1 on 04.09.2026 [skoirala]: c_flow_ME_vec allocated here; dead c_flow_MEQP_array parameter and the transcribed c_flow_A_array removed
 - 1.2 on 09.09.2026 [skoirala]: ingested cMicrobialEfficiency_CASA's 8 static constants as parameters here, applied to c_flow_ME_vec in define; cMicrobialEfficiency_CASA and the three per-group cMicrobialEfficiencyc{Lit,Mic,Soil}_CASA factors removed, since their static values duplicated these
 - 1.3 on 10.09.2026 [skoirala]: the four *_age_per_PFT fields (still unwired into precompute) keyed by canonical PFT name (PFTCatalog_SINDBAD_PFT) instead of a positional index; became fixed named lookups (CVEG_ROOTFINE_LEAF_AGE_PER_PFT, CVEG_ROOTCOARSE_WOOD_AGE_PER_PFT) plus bounded scalar multipliers, since array-valued struct fields cannot be optimized
 - 1.4 on 10.09.2026 [skoirala]: this file had never actually been run end to end -- ported it onto the working cCycleBase_GSI_PlantForm.jl pattern to fix what surfaced: `annk` became the fixed CASA_ANNK lookup plus an optimizable annk_scalar, matching the *_age_per_PFT treatment above; the ME-table and per-pool-turnover value computation moved from define into precompute, since define runs once ever and cannot pick up a parameter value the optimizer later changes; C_to_N_cVeg/c_eco_k_base's bulk `.=`/tuple-indexed assignments were replaced with @rep_elem loops, since land.diagnostics arrays are immutable SVectors; and c_eco_k_base, previously never allocated, is now defined and packed like every other diagnostic here
 - 1.5 on 10.09.2026 [skoirala]: meCASAFlowsLitter/meCASAFlowsSoil moved here from cMicrobialEfficiencycLit/cMicrobialEfficiencycSoil, since this is their only caller and a plain helper function has no reason to live in a different process's namespace than the one approach that calls it
 - 1.6 on 10.09.2026 [skoirala]: CVEG_ROOTFINE_LEAF_AGE_PER_PFT and CVEG_ROOTCOARSE_WOOD_AGE_PER_PFT moved to the consolidated vegTypeParamCatalog.jl as CVEG_ROOTFINE_LEAF_AGE_PER_VEGTYPE/CVEG_ROOTCOARSE_WOOD_AGE_PER_VEGTYPE, alongside every other per-vegetation-type fixed table; the four *_age_scalar fields stay here since they are this approach's own calibration parameters, still unwired into precompute
 - 1.7 on 11.09.2026 [skoirala]: CASA_ANNK moved to poolConfigurations/CASA.jl as
   CASA_TAU, re-expressed as turnover time (years) instead of rate, renamed
   annk_scalar to k_c_scalar to match the same convention now used in GSI; the
   4-element p_C_to_N_cVeg vector (read only for cVeg pools) replaced by the
   full-pool-coverage CASA_CN_ratio table (poolConfigurations/CASA.jl, 0.0 for every
   non-vegetation pool) plus a single CN_ratio_scalar; both turnover and C:N
   now applied via a generic per-pool-name loop instead of one hand-written loop per
   pool. The frozen pre-change behavior is preserved, unchanged, as
   `cCycleBase_CASA_Legacy`, with its own private `CASA_ANNK_Legacy` copy. Also:
   `define`'s `c_model` now packs `params` itself rather than a freshly
   constructed `cCycleBase_CASA()`, since `land.models` is only ever read for its
   type (pure dispatch), so the fresh instance only threw away whatever values
   `params` actually held for no benefit. `cVegRootFine_age_scalar`/
   `cVegRootCoarse_age_scalar`/`cVegWood_age_scalar`/`cVegLeaf_age_scalar`
   renamed to `rootfine_age_scalar`/`rootcoarse_age_scalar`/`wood_age_scalar`/
   `leaf_age_scalar`, dropping the redundant `cVeg` prefix to match the lowercase
   organ-name style `k_c_root_scalar` etc. already use.
 - 1.8 on 11.09.2026 [skoirala]: fixed a bug that predates this file's ever
   having run end to end (see 1.4): `k_c_scalar` (and `annk_scalar` before it)
   had `""` (no) declared timescale, and neither did `CASA_ANNK`/`CASA_TAU` (a
   plain `const`), so nothing rescaled the year-based turnover time to the
   model's actual configured timestep -- at a daily model, every turnover rate
   would come out roughly 365x too fast. Declaring `k_c_scalar` `"year"` fixes
   it, since `getTypedModel`/`getParameters` rescale a `"year"`-timescale
   field's default (and bounds) to the model's timestep before a run starts,
   the same mechanism GSI-family `cCycleBase` approaches were fixed with this
   same day (see their own 1.3-1.5 entries). Not independently verifiable
   end to end here yet, since this approach still fails earlier at `define`
   (the pre-existing, already-tracked `allowed_to_fail_approaches` pool-
   structure-mismatch issue), but confirmed correct via direct inspection of
   `getTypedModel(:cCycleBase_CASA, "day", Float32).k_c_scalar == 1/365`.

*Created by*
 - ncarvalhais
"""
cCycleBase_CASA
