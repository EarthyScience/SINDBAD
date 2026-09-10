export cQualityPartitioncLit_vegTypesLegacy

#! format: off
@bounds @describe @units @timescale @with_kw struct cQualityPartitioncLit_vegTypesLegacy{T1,T2} <: cQualityPartitioncLit
    frac_lignin_struct_scalar::T1 = 1.0 | (0.25, 4.0) | "scalar for the per-vegetation-type lignin fraction of structural litter" | "-" | ""
    frac_lignin_wood_scalar::T2 = 1.0 | (0.25, 4.0) | "scalar for the per-vegetation-type lignin fraction of woody litter" | "-" | ""
end
#! format: on

function define(params::cQualityPartitioncLit_vegTypesLegacy, forcing, land, helpers)
    @unpack_nt begin
        c_taker ⇐ land.cCycleBase
        cEco ⇐ land.pools
        veg_type_classification ⇐ land.vegTypes
    end

    # One value per active carbon transfer, neutral so that every flow this process
    # does not own leaves the partition to the other factors.
    c_flow_QP_f_cLit = getVectorOfType(cEco, length(c_taker), one)

    # Re-keyed once, at define time, onto whichever classification the experiment's
    # vegTypes approach resolved into (the canonical vocabulary, or a grouping like
    # VegTypeCatalog_PlantForm) -- see vegTypeCatalogFor.
    frac_lignin_struct_per_vegtype = vegTypeCatalogFor(FRAC_LIGNIN_STRUCT_PER_VEGTYPE, typeof(veg_type_classification))
    frac_lignin_wood_per_vegtype = vegTypeCatalogFor(FRAC_LIGNIN_WOOD_PER_VEGTYPE, typeof(veg_type_classification))

    @pack_nt (c_flow_QP_f_cLit, frac_lignin_struct_per_vegtype, frac_lignin_wood_per_vegtype) ⇒ land.diagnostics
    return land
end

function precompute(params::cQualityPartitioncLit_vegTypesLegacy, forcing, land, helpers)
    ## unpack parameters
    @unpack_cQualityPartitioncLit_vegTypesLegacy params

    ## unpack land variables
    @unpack_nt begin
        c_flow_QP_f_cLit ⇐ land.diagnostics
        frac_lignin_struct_per_vegtype ⇐ land.diagnostics
        frac_lignin_wood_per_vegtype ⇐ land.diagnostics
        c_flow_named_edges ⇐ land.cCycleBase
        veg_type ⇐ land.states
        o_one ⇐ land.constants
    end

    ## calculate variables
    # Selected by land.states.veg_type, whatever classification (fine canonical, or a
    # grouping such as tree/shrub/herb) produced it, rather than a positional index
    # into an array tied to one specific classification. The per-vegetation-type
    # tables are plain Float64 literals; oftype matches each looked-up value to its
    # scalar's type before multiplying, so the result stays the parameter type
    # instead of silently widening to Float64.
    frac_lignin_struct = oftype(frac_lignin_struct_scalar, getproperty(frac_lignin_struct_per_vegtype, veg_type)) * frac_lignin_struct_scalar
    frac_lignin_wood = oftype(frac_lignin_wood_scalar, getproperty(frac_lignin_wood_per_vegtype, veg_type)) * frac_lignin_wood_scalar

    for (stabilized_edge, microbial_edge) ∈ QP_CLIT_STRUCT_GROUPS
        c_flow_QP_f_cLit = setQPGroup(c_flow_QP_f_cLit, c_flow_named_edges,
            (stabilized_edge, microbial_edge),
            (frac_lignin_struct, o_one - frac_lignin_struct))
    end
    for (stabilized_edge, microbial_edge) ∈ QP_CLIT_WOOD_GROUPS
        c_flow_QP_f_cLit = setQPGroup(c_flow_QP_f_cLit, c_flow_named_edges,
            (stabilized_edge, microbial_edge),
            (frac_lignin_wood, o_one - frac_lignin_wood))
    end

    ## pack land variables
    @pack_nt c_flow_QP_f_cLit ⇒ land.diagnostics
    return land
end

purpose(::Type{cQualityPartitioncLit_vegTypesLegacy}) = "Lignin control of the carbon-quality partition looked up per vegetation type class, separately for structural and woody litter."

@doc """

	$(getModelDocString(cQualityPartitioncLit_vegTypesLegacy))

---

# Extended help

Kept as a legacy alternative to [`cQualityPartitioncLit_vegQualityTraits`](@ref),
to be revisited later. The approach re-keys `FRAC_LIGNIN_STRUCT_PER_VEGTYPE` and
`FRAC_LIGNIN_WOOD_PER_VEGTYPE` (declared in `vegTypeParamCatalog.jl`) onto whichever
classification the experiment's `vegTypes` approach resolved into, selects each entry
for `land.states.veg_type`, scales each by its bounded scalar
(`frac_lignin_struct_scalar`, `frac_lignin_wood_scalar`, since the per-vegetation-type
tables themselves are fixed data excluded from optimization), and writes each, with
its complement, into the flows of `QP_CLIT_STRUCT_GROUPS` and `QP_CLIT_WOOD_GROUPS`.
This table is its own independent calibration: unlike
`cQualityPartitioncLit_vegQualityTraits`, it does not read
`land.properties.lit_frac_lignin_struct`/`lit_frac_lignin_wood`, so it can silently
disagree with whatever `vegQualityTraits` approach is selected.

The structural defaults are the CASA relation
`clamp_zero_one(lit_frac_lignin * 0.65 * 2.22 / (1 - lit_frac_metabolic))`
evaluated over the per-vegetation-type litter chemistry of `vegQualityTraits_CASA`, so
this approach starts from the values that approach's lignin term produces while
leaving them free to be calibrated on their own. The woody defaults are the
single CASA value, 0.4, which that approach does not resolve per vegetation type.
`Cereal_Croplands` (position 8 of the legacy arrays these tables were
transcribed from) has no lignin in that chemistry and therefore gets zero in
both -- see `FRAC_LIGNIN_STRUCT_PER_VEGTYPE`'s docstring for why that value does
not survive separately once collapsed onto IGBP's single `Croplands` class.

*References*
 - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.

*Versions*
 - 1.0 on 04.09.2026 [skoirala]: as cQualityPartitionLignin_PFT
 - 2.0 on 10.09.2026 [skoirala]: renamed/relocated into cQualityPartitioncLit, kept as legacy
 - 3.0 on 10.09.2026 [skoirala]: per-PFT lookups keyed by canonical PFT name
   (PFTCatalog_SINDBAD_PFT) instead of a positional index; the per-PFT arrays
   became fixed named lookups plus bounded scalar multipliers, since
   array-valued struct fields cannot be optimized
 - 4.0 on 10.09.2026 [skoirala]: the fixed tables moved to the consolidated
   `vegTypeParamCatalog.jl`, re-keyed at `define` time onto the active
   `vegTypes` classification via `vegTypeCatalogFor` instead of being read
   directly by canonical PFT name
 - 5.0 on 10.09.2026 [skoirala]: renamed from `cQualityPartitioncLit_PFT` to
   `cQualityPartitioncLit_vegTypesLegacy` -- `_vegTypes` alone, tried briefly,
   read as too close to the sibling `cQualityPartitioncLit_vegQualityTraits`
   given both now touch vegetation-type data; `Legacy` names the actual
   distinction instead: this approach owns independent per-vegetation-type
   tables and reads `land.states.veg_type` directly, rather than delegating to
   `vegQualityTraits`/`land.properties` the way the other approach does. No
   behavior change.

*Created by*
 - skoirala

"""
cQualityPartitioncLit_vegTypesLegacy
