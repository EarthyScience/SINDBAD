export vegTypes_forcing_MODIS_BGC

struct vegTypes_forcing_MODIS_BGC <: vegTypes end

vegTypeCatalog(::Type{vegTypes_forcing_MODIS_BGC}) = VegTypeCatalog_MODIS_BGC
vegTypeClassification(::Type{vegTypes_forcing_MODIS_BGC}) = VegTypeCatalog_SINDBAD

function precompute(params::vegTypes_forcing_MODIS_BGC, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    veg_type, veg_type_source, veg_type_code = resolveVegType(
        VegTypeCatalog_MODIS_BGC, VegTypeCatalog_SINDBAD, f_pft)

    ## pack land variables
    @pack_nt (veg_type, veg_type_source, veg_type_code) ⇒ land.states
    return land
end

purpose(::Type{vegTypes_forcing_MODIS_BGC}) = "Gets the vegetation type from BIOME-BGC-classified forcing data."

@doc """

$(getModelDocString(vegTypes_forcing_MODIS_BGC))

---

# Extended help

Same as [`vegTypes_forcing_MODIS_IGBP`](@ref), interpreting `f_pft` against the
BIOME-Biogeochemical Cycles legend (`VegTypeCatalog_MODIS_BGC`) instead of IGBP.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]
 - 2.0 on 10.09.2026 [skoirala]: merged into the unified `vegTypes` process
   (was `PFT_forcing_MODIS_BGC`)

*Created by*
 - skoirala
"""
vegTypes_forcing_MODIS_BGC
