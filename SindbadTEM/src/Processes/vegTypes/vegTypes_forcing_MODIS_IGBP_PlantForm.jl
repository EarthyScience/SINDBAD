export vegTypes_forcing_MODIS_IGBP_PlantForm

struct vegTypes_forcing_MODIS_IGBP_PlantForm <: vegTypes end

vegTypeCatalog(::Type{vegTypes_forcing_MODIS_IGBP_PlantForm}) = VegTypeCatalog_MODIS_IGBP
vegTypeClassification(::Type{vegTypes_forcing_MODIS_IGBP_PlantForm}) = VegTypeCatalog_PlantForm

function precompute(params::vegTypes_forcing_MODIS_IGBP_PlantForm, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    veg_type, veg_type_source, veg_type_code = resolveVegType(
        VegTypeCatalog_MODIS_IGBP, VegTypeCatalog_PlantForm, f_pft[1])

    ## pack land variables
    @pack_nt (veg_type, veg_type_source, veg_type_code) ⇒ land.states
    return land
end

purpose(::Type{vegTypes_forcing_MODIS_IGBP_PlantForm}) = "Gets the vegetation type from IGBP-classified forcing data, grouped into tree/shrub/herb plant forms."

@doc """

$(getModelDocString(vegTypes_forcing_MODIS_IGBP_PlantForm))

---

# Extended help

Identical to [`vegTypes_forcing_MODIS_IGBP`](@ref) except its target classification is
`VegTypeCatalog_PlantForm` instead of the canonical vocabulary, so `land.states.veg_type`
holds `:tree`/`:shrub`/`:herb`/`:unknown` rather than one of the 18 canonical classes.
Replaces the former `plantForm_PFT` approach's grouping step, now expressed as data on
`VegTypeCatalog_PlantForm` (`vegTypeClasses`) rather than logic inside this file.

Select this approach (rather than the plain `vegTypes_forcing_MODIS_IGBP`) when the
downstream `cCycleBase` approach is `cCycleBase_GSI_PlantForm`/`_MGMT`, which reads
`land.states.veg_type` grouped this way. Do not combine it with a consumer that expects
the fine canonical vocabulary (`vegQualityTraits_CASA`,
`cQualityPartitioncVeg_vegTypesLegacy`/`cQualityPartitioncLit_vegTypesLegacy`,
`runoffSaturationExcess_Bergstroem1992VegFractionPFT`) -- see `vegTypes`'s own
docstring for this limitation.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]: new, replacing the former separate
   `PFT_forcing_MODIS_IGBP` + `plantForm_PFT` two-process pipeline

*Created by*
 - skoirala
"""
vegTypes_forcing_MODIS_IGBP_PlantForm
