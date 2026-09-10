export vegTypes_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct vegTypes_constant{T1} <: vegTypes
    veg_type_code::T1 = 1.0 | (1.0, 17.0) | "Vegetation type class, per SINDBAD's canonical vegetation-type vocabulary (VegTypeCatalog_SINDBAD)" | "class" | ""
end
#! format: on

vegTypeCatalog(::Type{<:vegTypes_constant}) = VegTypeCatalog_SINDBAD
vegTypeClassification(::Type{<:vegTypes_constant}) = VegTypeCatalog_SINDBAD

function precompute(params::vegTypes_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegTypes_constant params

    veg_type, veg_type_source, veg_type_code = resolveVegType(
        VegTypeCatalog_SINDBAD, VegTypeCatalog_SINDBAD, round(Int, veg_type_code))

    ## pack land variables
    @pack_nt (veg_type, veg_type_source, veg_type_code) ⇒ land.states
    return land
end

purpose(::Type{vegTypes_constant}) = "Sets a uniform vegetation-type class, given as a canonical vegetation-type class number."

@doc """

$(getModelDocString(vegTypes_constant))

---

# Extended help

Unlike `vegTypes_forcing_*`, this approach has no real data source to interpret a
raw code against, so it is written directly in terms of SINDBAD's canonical
vegetation-type vocabulary (`VegTypeCatalog_SINDBAD`) rather than needing one variant
per source catalog: `veg_type_code` is rounded to the nearest canonical class and
resolved via `resolveVegType`, which for this catalog is always the identity
(`veg_type` and `veg_type_source` are always equal here).

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 2.0 on 10.09.2026 [skoirala]: resolved through the PFT catalog machinery
   instead of publishing a raw numeric code with no declared classification
 - 3.0 on 10.09.2026 [skoirala]: collapsed the five catalog-specific variants
   back into one approach, written directly against the canonical
   PFTCatalog_SINDBAD_PFT vocabulary, since this approach has no real data
   source to interpret a raw code against
 - 4.0 on 10.09.2026 [skoirala]: merged into the unified `vegTypes` process
   (was `PFT_constant`), resolving through the two-step
   `vegTypeCatalog`/`vegTypeClassification` mechanism

*Created by*
 - unknown [xxx]
"""
vegTypes_constant
