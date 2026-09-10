export PFT_forcing_MODIS_BGC

struct PFT_forcing_MODIS_BGC <: PFT end

pftCatalog(::Type{PFT_forcing_MODIS_BGC}) = PFTCatalog_MODIS_BGC

function precompute(params::PFT_forcing_MODIS_BGC, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    PFT, PFT_source, PFT_code = resolvePFT(PFTCatalog_MODIS_BGC, f_pft[1])

    ## pack land variables
    @pack_nt (PFT, PFT_source, PFT_code) ⇒ land.states
    return land
end

purpose(::Type{PFT_forcing_MODIS_BGC}) = "Gets the PFT class from BIOME-BGC-classified forcing data."

@doc """

$(getModelDocString(PFT_forcing_MODIS_BGC))

---

# Extended help

Same as [`PFT_forcing_MODIS_IGBP`](@ref), interpreting `f_pft` against the
BIOME-Biogeochemical Cycles legend (`PFTCatalog_MODIS_BGC`) instead of IGBP.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]

*Created by*
 - skoirala
"""
PFT_forcing_MODIS_BGC
