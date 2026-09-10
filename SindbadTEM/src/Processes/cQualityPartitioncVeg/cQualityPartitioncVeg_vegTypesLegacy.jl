export cQualityPartitioncVeg_vegTypesLegacy

#! format: off
@bounds @describe @units @timescale @with_kw struct cQualityPartitioncVeg_vegTypesLegacy{T1} <: cQualityPartitioncVeg
    frac_metabolic_scalar::T1 = 1.0 | (0.25, 4.0) | "scalar for the per-vegetation-type metabolic litter fraction" | "-" | ""
end
#! format: on

function define(params::cQualityPartitioncVeg_vegTypesLegacy, forcing, land, helpers)
    @unpack_nt begin
        c_taker ⇐ land.cCycleBase
        cEco ⇐ land.pools
        veg_type_classification ⇐ land.vegTypes
    end

    # One value per active carbon transfer, neutral so that every flow this process
    # does not own leaves the partition to the other factors.
    c_flow_QP_f_cVeg = getVectorOfType(cEco, length(c_taker), one)

    # Re-keyed once, at define time, onto whichever classification the experiment's
    # vegTypes approach resolved into (the canonical vocabulary, or a grouping like
    # VegTypeCatalog_PlantForm) -- see vegTypeCatalogFor.
    frac_metabolic_per_vegtype = vegTypeCatalogFor(FRAC_METABOLIC_PER_VEGTYPE, typeof(veg_type_classification))

    @pack_nt (c_flow_QP_f_cVeg, frac_metabolic_per_vegtype) ⇒ land.diagnostics
    return land
end

function precompute(params::cQualityPartitioncVeg_vegTypesLegacy, forcing, land, helpers)
    ## unpack parameters
    @unpack_cQualityPartitioncVeg_vegTypesLegacy params

    ## unpack land variables
    @unpack_nt begin
        c_flow_QP_f_cVeg ⇐ land.diagnostics
        frac_metabolic_per_vegtype ⇐ land.diagnostics
        c_flow_named_edges ⇐ land.cCycleBase
        veg_type ⇐ land.states
        o_one ⇐ land.constants
    end

    ## calculate variables
    # Selected by land.states.veg_type, whatever classification (fine canonical, or a
    # grouping such as tree/shrub/herb) produced it, rather than a positional index
    # into an array tied to one specific classification. frac_metabolic_per_vegtype
    # is plain Float64 literals; oftype matches the looked-up value to the scalar's
    # type before multiplying, so the result stays the parameter type instead of
    # silently widening to Float64.
    frac_metabolic = oftype(frac_metabolic_scalar, getproperty(frac_metabolic_per_vegtype, veg_type)) * frac_metabolic_scalar

    for (metabolic_edge, structural_edge) ∈ QP_CVEG_GROUPS
        c_flow_QP_f_cVeg = setQPGroup(c_flow_QP_f_cVeg,
            c_flow_named_edges, (metabolic_edge, structural_edge),
            (frac_metabolic, o_one - frac_metabolic))
    end

    ## pack land variables
    @pack_nt c_flow_QP_f_cVeg ⇒ land.diagnostics
    return land
end

purpose(::Type{cQualityPartitioncVeg_vegTypesLegacy}) = "Metabolic litter fraction of the carbon-quality partition looked up per vegetation type class."

@doc """

	$(getModelDocString(cQualityPartitioncVeg_vegTypesLegacy))

---

# Extended help

Kept as a legacy alternative to [`cQualityPartitioncVeg_vegQualityTraits`](@ref),
to be revisited later. The approach re-keys `FRAC_METABOLIC_PER_VEGTYPE` (declared in
`vegTypeParamCatalog.jl`) onto whichever classification the experiment's `vegTypes`
approach resolved into, selects the entry for `land.states.veg_type`, scales it by the
bounded `frac_metabolic_scalar` (since the per-vegetation-type table itself is fixed
data excluded from optimization), and writes it, with its complement, into the flows
of `QP_CVEG_GROUPS`. This table is its own independent calibration: unlike
`cQualityPartitioncVeg_vegQualityTraits`, it does not read
`land.properties.lit_frac_metabolic`, so it can silently disagree with whatever
`vegQualityTraits` approach is selected.

The defaults are the CASA relation
`clamp_zero_one(0.85 - 0.018 * lit_C_to_N * lit_frac_lignin * 2.22)` evaluated
over the per-vegetation-type litter chemistry of `vegQualityTraits_CASA`, so this
approach starts from the values CASA produces while leaving them free to be calibrated
on their own. `Cereal_Croplands` (position 8 of the legacy array this table was
transcribed from) has no lignin in that chemistry and therefore keeps the
intercept, 0.85 -- see `FRAC_METABOLIC_PER_VEGTYPE`'s docstring for why that value
does not survive separately once collapsed onto IGBP's single `Croplands`
class.

*References*
 - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.

*Versions*
 - 1.0 on 04.09.2026 [skoirala]: as cQualityPartitionMetabolicFraction_PFT
 - 2.0 on 10.09.2026 [skoirala]: renamed/relocated into cQualityPartitioncVeg, kept as legacy
 - 3.0 on 10.09.2026 [skoirala]: per-PFT lookup keyed by canonical PFT name
   (PFTCatalog_SINDBAD_PFT) instead of a positional index; the per-PFT array
   became a fixed named lookup plus a bounded scalar multiplier, since
   array-valued struct fields cannot be optimized
 - 4.0 on 10.09.2026 [skoirala]: the fixed table moved to the consolidated
   `vegTypeParamCatalog.jl` as `FRAC_METABOLIC_PER_VEGTYPE`, re-keyed at
   `define` time onto the active `vegTypes` classification via
   `vegTypeCatalogFor` instead of being read directly by canonical PFT name
 - 5.0 on 10.09.2026 [skoirala]: renamed from `cQualityPartitioncVeg_PFT` to
   `cQualityPartitioncVeg_vegTypesLegacy` -- `_vegTypes` alone, tried briefly,
   read as too close to the sibling `cQualityPartitioncVeg_vegQualityTraits`
   given both now touch vegetation-type data; `Legacy` names the actual
   distinction instead: this approach owns an independent per-vegetation-type
   table and reads `land.states.veg_type` directly, rather than delegating to
   `vegQualityTraits`/`land.properties` the way the other approach does. No
   behavior change.

*Created by*
 - skoirala

"""
cQualityPartitioncVeg_vegTypesLegacy
