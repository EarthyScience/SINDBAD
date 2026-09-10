export vegTypes

abstract type vegTypes <: LandEcosystem end

purpose(::Type{vegTypes}) = "Vegetation-type classification of the pixel: resolves a raw code (forcing or constant) to a canonical name, then optionally crosswalks that into a coarser classification, in one step."

# Catalogs and their crosswalks are included explicitly before the approaches load,
# matching how cCycleBase.jl includes poolConfigurations.jl before its own approaches:
# includeApproaches globs vegTypes_*.jl in this directory and does not descend, so it
# skips the vegTypeCatalogs/ subfolder.
include("vegTypeCatalogs/vegTypeCatalogs.jl")

"""
    resolvedVegTypeClassification(::Type{X}) where {X <: LandEcosystem}

Resolve the `vegTypeClassification` trait's `nothing` default (declared in `Types.jl`,
which cannot reference a concrete `VegTypeCatalog` subtype) to the canonical
vocabulary, `VegTypeCatalog_SINDBAD` -- the "no grouping" target every
`vegTypes_forcing_*`/`vegTypes_constant` approach resolves into unless it opts into a
coarser one (e.g. a `_PlantForm` variant).
"""
resolvedVegTypeClassification(::Type{X}) where {X <: LandEcosystem} =
    something(vegTypeClassification(X), VegTypeCatalog_SINDBAD)

"""
    resolveVegType(::Type{SourceCatalog}, ::Type{Classification}, raw_code)

Shared resolution step for every `vegTypes_forcing_*`/`vegTypes_constant*` approach,
composed of two steps:

1. `raw_code` resolved against `SourceCatalog`'s own crosswalk to the canonical
   `VegTypeCatalog_SINDBAD` name (`veg_type_source` is `SourceCatalog`'s own name for
   that code, kept for provenance/output metadata only; `veg_type_code` is the raw
   number, unchanged, passed back through) -- unchanged from the old `resolvePFT`.
2. The canonical name resolved against `Classification`'s own crosswalk
   (`vegTypeClassOf`), giving `veg_type`, the name every downstream science approach
   reads. This step is a no-op when `Classification` is `VegTypeCatalog_SINDBAD`
   itself, with no special case needed: `vegTypeClassOf` treats identity as a
   one-element grouping.

Errors (via `vegTypeName`/`vegTypeClassOf`) rather than clamps when a code or name is
not known, so a bad code or an uncovered class fails at the point it was produced
instead of silently aliasing to the wrong class further downstream.
"""
function resolveVegType(::Type{SourceCatalog}, ::Type{Classification}, raw_code) where
        {SourceCatalog <: VegTypeCatalog, Classification <: VegTypeCatalog}
    veg_type_source = vegTypeName(SourceCatalog, raw_code)
    canonical_name = vegTypeCanonicalName(SourceCatalog, raw_code)
    canonical_name isa Symbol || error(
        "$(nameof(SourceCatalog)) is a grouping catalog (its own crosswalk target is " *
        "a tuple), so it cannot be used as the raw-code source of resolveVegType. " *
        "Source catalogs must crosswalk one-to-one onto VegTypeCatalog_SINDBAD.")
    veg_type = vegTypeClassOf(Classification, canonical_name)
    return veg_type, veg_type_source, raw_code
end

"""
    define(params::vegTypes, forcing, land, helpers)

Shared `define` for every `vegTypes` approach: packs an instance of the approach's
resolved target classification into `land.vegTypes`, so downstream consumers (e.g.
`cQualityPartitioncVeg_vegTypesLegacy`) can read back which classification is active and derive
their own per-classification default tables from it via `vegTypeCatalogFor`, without
each approach needing to repeat this. Mirrors `cCycleBase_GSI_PlantForm` packing
`c_model = cCycleBase_GSI_PlantForm()` into `land.models` for the same kind of
downstream dispatch.

Declared once here, generically over `vegTypes`, rather than in each approach file,
since every approach does exactly this and nothing else at `define` time.
"""
function define(params::vegTypes, forcing, land, helpers)
    veg_type_classification = resolvedVegTypeClassification(typeof(params))()
    @pack_nt veg_type_classification ⇒ land.vegTypes
    return land
end

includeApproaches(vegTypes, @__DIR__)

@doc """
    $(getModelDocString(vegTypes))

---

# Extended help

Replaces the former separate `PFT` and `plantForm` processes: one process now both
resolves a raw vegetation-classification code and, optionally, groups the result into
a coarser classification, writing a single `land.states.veg_type` (plus
`veg_type_source`/`veg_type_code` for provenance) that every downstream science
approach reads.

Each concrete approach declares two traits: `vegTypeCatalog`, the source catalog its
raw code is interpreted against (a forcing legend, or the canonical vocabulary itself
for a constant approach), and `vegTypeClassification`, the target classification to
crosswalk into (defaulting to `VegTypeCatalog_SINDBAD`, i.e. no grouping, when
unset). A `_PlantForm`-suffixed approach (e.g. `vegTypes_forcing_MODIS_IGBP_PlantForm`)
is the same resolution with `vegTypeClassification` set to `VegTypeCatalog_PlantForm`
instead -- composition via a second small approach file, rather than a second
`model_structure.json` field or a struct type parameter, since neither fits how
approaches are otherwise selected in this codebase.

**Known limitation**: because `land.states.veg_type` is a single field, one experiment
cannot combine a consumer that expects the fine canonical vocabulary (e.g.
`vegQualityTraits_CASA`, `cQualityPartitioncVeg_vegTypesLegacy`/`cQualityPartitioncLit_vegTypesLegacy`,
`runoffSaturationExcess_Bergstroem1992VegFractionPFT`) with one that expects a grouped
classification (e.g. `cCycleBase_GSI_PlantForm`/`_MGMT`) in the same run. Pick a
`vegTypes` approach whose target classification matches every downstream consumer
selected alongside it.

*Versions*
 - 1.0 on 10.09.2026 [skoirala]: merged from the former `PFT` and `plantForm`
   processes into one, with a formal one-to-many crosswalk mechanism
   (`VegTypeCatalog_PlantForm`) replacing `plantForm_PFT`'s inline grouping table

*Created by*
 - skoirala
"""
vegTypes
