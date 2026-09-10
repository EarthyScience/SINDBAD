export PFT_forcing_MODIS_IGBP

struct PFT_forcing_MODIS_IGBP <: PFT end

pftCatalog(::Type{PFT_forcing_MODIS_IGBP}) = PFTCatalog_MODIS_IGBP

function precompute(params::PFT_forcing_MODIS_IGBP, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    PFT, PFT_source, PFT_code = resolvePFT(PFTCatalog_MODIS_IGBP, f_pft[1])

    ## pack land variables
    @pack_nt (PFT, PFT_source, PFT_code) ⇒ land.states
    return land
end

purpose(::Type{PFT_forcing_MODIS_IGBP}) = "Gets the PFT class from IGBP-classified forcing data."

@doc """

$(getModelDocString(PFT_forcing_MODIS_IGBP))

---

# Extended help

The PFT class is taken from the `f_pft` forcing variable, interpreted against
the MODIS IGBP legend (`PFTCatalog_MODIS_IGBP`), and resolved via
`pftCanonicalName` to `PFTCatalog_SINDBAD_PFT`'s canonical PFT vocabulary
before being published as `land.states.PFT`, the single name every
downstream PFT-dependent process reads. The IGBP-specific name and the raw
numeric code are also published, as `land.states.PFT_source` and
`land.states.PFT_code`, for provenance and output metadata only; no science
approach should read either. PFT is time invariant, so it is resolved once
in `precompute`.

*References*

*Versions*
 - 1.0 on 04.09.2026 [skoirala]
 - 2.0 on 10.09.2026 [skoirala]: split from the generic PFT_forcing into one
   approach per source catalog, resolving through SINDBAD's canonical PFT
   vocabulary instead of publishing a raw, catalog-ambiguous numeric code

*Created by*
 - skoirala
"""
PFT_forcing_MODIS_IGBP
