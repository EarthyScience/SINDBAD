export vegTypes_forcing_MODIS_UMD

struct vegTypes_forcing_MODIS_UMD <: vegTypes end

vegTypeCatalog(::Type{vegTypes_forcing_MODIS_UMD}) = VegTypeCatalog_MODIS_UMD
vegTypeClassification(::Type{vegTypes_forcing_MODIS_UMD}) = VegTypeCatalog_SINDBAD

function precompute(params::vegTypes_forcing_MODIS_UMD, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    veg_type, veg_type_source, veg_type_code = resolveVegType(
        VegTypeCatalog_MODIS_UMD, VegTypeCatalog_SINDBAD, f_pft[1])

    ## pack land variables
    @pack_nt (veg_type, veg_type_source, veg_type_code) ⇒ land.states
    return land
end

purpose(::Type{vegTypes_forcing_MODIS_UMD}) = "Gets the vegetation type from UMD-classified forcing data."

@doc """

$(getModelDocString(vegTypes_forcing_MODIS_UMD))

---

# Extended help

Same as [`vegTypes_forcing_MODIS_IGBP`](@ref), interpreting `f_pft` against the
University of Maryland legend (`VegTypeCatalog_MODIS_UMD`) instead of IGBP.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]
 - 2.0 on 10.09.2026 [skoirala]: merged into the unified `vegTypes` process
   (was `PFT_forcing_MODIS_UMD`)

*Created by*
 - skoirala
"""
vegTypes_forcing_MODIS_UMD
