export vegTypes_forcing_MODIS_IGBP

struct vegTypes_forcing_MODIS_IGBP <: vegTypes end

vegTypeCatalog(::Type{vegTypes_forcing_MODIS_IGBP}) = VegTypeCatalog_MODIS_IGBP
vegTypeClassification(::Type{vegTypes_forcing_MODIS_IGBP}) = VegTypeCatalog_SINDBAD

function precompute(params::vegTypes_forcing_MODIS_IGBP, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    veg_type, veg_type_source, veg_type_code = resolveVegType(
        VegTypeCatalog_MODIS_IGBP, VegTypeCatalog_SINDBAD, f_pft[1])

    ## pack land variables
    @pack_nt (veg_type, veg_type_source, veg_type_code) ⇒ land.states
    return land
end

purpose(::Type{vegTypes_forcing_MODIS_IGBP}) = "Gets the vegetation type from IGBP-classified forcing data."

@doc """

$(getModelDocString(vegTypes_forcing_MODIS_IGBP))

---

# Extended help

The vegetation-type class is taken from the `f_pft` forcing variable, interpreted
against the MODIS IGBP legend (`VegTypeCatalog_MODIS_IGBP`), and resolved to
`VegTypeCatalog_SINDBAD`'s canonical vocabulary before being published as
`land.states.veg_type`, the single name every downstream vegetation-type-dependent
process reads. The IGBP-specific name and the raw numeric code are also published, as
`land.states.veg_type_source` and `land.states.veg_type_code`, for provenance and
output metadata only; no science approach should read either. Vegetation type is time
invariant, so it is resolved once in `precompute`.

*References*

*Versions*
 - 1.0 on 04.09.2026 [skoirala]
 - 2.0 on 10.09.2026 [skoirala]: split from the generic PFT_forcing into one
   approach per source catalog, resolving through SINDBAD's canonical PFT
   vocabulary instead of publishing a raw, catalog-ambiguous numeric code
 - 3.0 on 10.09.2026 [skoirala]: merged into the unified `vegTypes` process
   (was `PFT_forcing_MODIS_IGBP`); resolves through the two-step
   `vegTypeCatalog`/`vegTypeClassification` mechanism, defaulting to the
   canonical vocabulary (no grouping) -- see
   `vegTypes_forcing_MODIS_IGBP_PlantForm` for the grouped variant

*Created by*
 - skoirala
"""
vegTypes_forcing_MODIS_IGBP
