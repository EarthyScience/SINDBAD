export vegTypes_forcing_MODIS_LAI

struct vegTypes_forcing_MODIS_LAI <: vegTypes end

vegTypeCatalog(::Type{vegTypes_forcing_MODIS_LAI}) = VegTypeCatalog_MODIS_LAI
vegTypeClassification(::Type{vegTypes_forcing_MODIS_LAI}) = VegTypeCatalog_SINDBAD

function precompute(params::vegTypes_forcing_MODIS_LAI, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    veg_type, veg_type_source, veg_type_code = resolveVegType(
        VegTypeCatalog_MODIS_LAI, VegTypeCatalog_SINDBAD, f_pft)

    ## pack land variables
    @pack_nt (veg_type, veg_type_source, veg_type_code) ⇒ land.states
    return land
end

purpose(::Type{vegTypes_forcing_MODIS_LAI}) = "Gets the vegetation type from LAI/fPAR-biome-classified forcing data."

@doc """

$(getModelDocString(vegTypes_forcing_MODIS_LAI))

---

# Extended help

Same as [`vegTypes_forcing_MODIS_IGBP`](@ref), interpreting `f_pft` against the
LAI/fPAR biome legend (`VegTypeCatalog_MODIS_LAI`) instead of IGBP.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]
 - 2.0 on 10.09.2026 [skoirala]: merged into the unified `vegTypes` process
   (was `PFT_forcing_MODIS_LAI`)

*Created by*
 - skoirala
"""
vegTypes_forcing_MODIS_LAI
