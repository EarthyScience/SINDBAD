export vegTypes_forcing_MODIS_PFT

struct vegTypes_forcing_MODIS_PFT <: vegTypes end

vegTypeCatalog(::Type{vegTypes_forcing_MODIS_PFT}) = VegTypeCatalog_MODIS_PFT
vegTypeClassification(::Type{vegTypes_forcing_MODIS_PFT}) = VegTypeCatalog_SINDBAD

function precompute(params::vegTypes_forcing_MODIS_PFT, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    veg_type, veg_type_source, veg_type_code = resolveVegType(
        VegTypeCatalog_MODIS_PFT, VegTypeCatalog_SINDBAD, f_pft[1])

    ## pack land variables
    @pack_nt (veg_type, veg_type_source, veg_type_code) ⇒ land.states
    return land
end

purpose(::Type{vegTypes_forcing_MODIS_PFT}) = "Gets the vegetation type from Plant-Functional-Type-classified (MCD12Q1 Type 5) forcing data."

@doc """

$(getModelDocString(vegTypes_forcing_MODIS_PFT))

---

# Extended help

Same as [`vegTypes_forcing_MODIS_IGBP`](@ref), interpreting `f_pft` against the
MODIS PFT legend (`VegTypeCatalog_MODIS_PFT`, after Bonan (2002)) instead of
IGBP. `veg_type` (canonical, `VegTypeCatalog_SINDBAD`-keyed) and `veg_type_source`
(this legend's own name) generally differ here: see
`vegTypeClasses(::Type{VegTypeCatalog_MODIS_PFT})` for the
`Shrub`/`Cereal_Croplands`/`Broadleaf_Croplands` classes that collapse onto a
single canonical class.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]
 - 2.0 on 10.09.2026 [skoirala]: merged into the unified `vegTypes` process
   (was `PFT_forcing_MODIS_PFT`)

*Created by*
 - skoirala
"""
vegTypes_forcing_MODIS_PFT
