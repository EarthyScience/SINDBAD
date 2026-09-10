export PFT_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct PFT_constant{T1} <: PFT
    PFT_code::T1 = 1.0 | (1.0, 17.0) | "Plant functional type class, per SINDBAD's canonical PFT vocabulary (PFTCatalog_SINDBAD_PFT)" | "class" | ""
end
#! format: on

pftCatalog(::Type{<:PFT_constant}) = PFTCatalog_SINDBAD_PFT

function precompute(params::PFT_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_PFT_constant params

    PFT, PFT_source, PFT_code = resolvePFT(PFTCatalog_SINDBAD_PFT, round(Int, PFT_code))

    ## pack land variables
    @pack_nt (PFT, PFT_source, PFT_code) ⇒ land.states
    return land
end

purpose(::Type{PFT_constant}) = "Sets a uniform PFT class, given as a canonical PFT class number."

@doc """

$(getModelDocString(PFT_constant))

---

# Extended help

Unlike `PFT_forcing_*`, this approach has no real data source to interpret a
raw code against, so it is written directly in terms of SINDBAD's canonical
PFT vocabulary (`PFTCatalog_SINDBAD_PFT`) rather than needing one variant per
source catalog: `PFT_code` is rounded to the nearest canonical class and
resolved via `pftCanonicalName`, which for this catalog is always the
identity (`PFT` and `PFT_source` are always equal here).

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 2.0 on 10.09.2026 [skoirala]: resolved through the PFT catalog machinery
   instead of publishing a raw numeric code with no declared classification
 - 3.0 on 10.09.2026 [skoirala]: collapsed the five catalog-specific variants
   back into one approach, written directly against the canonical
   PFTCatalog_SINDBAD_PFT vocabulary, since this approach has no real data
   source to interpret a raw code against

*Created by*
 - unknown [xxx]
"""
PFT_constant
