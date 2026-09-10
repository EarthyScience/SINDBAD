export PFT_forcing_MODIS_UMD

struct PFT_forcing_MODIS_UMD <: PFT end

pftCatalog(::Type{PFT_forcing_MODIS_UMD}) = PFTCatalog_MODIS_UMD

function precompute(params::PFT_forcing_MODIS_UMD, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    PFT, PFT_source, PFT_code = resolvePFT(PFTCatalog_MODIS_UMD, f_pft[1])

    ## pack land variables
    @pack_nt (PFT, PFT_source, PFT_code) ⇒ land.states
    return land
end

purpose(::Type{PFT_forcing_MODIS_UMD}) = "Gets the PFT class from UMD-classified forcing data."

@doc """

$(getModelDocString(PFT_forcing_MODIS_UMD))

---

# Extended help

Same as [`PFT_forcing_MODIS_IGBP`](@ref), interpreting `f_pft` against the
University of Maryland legend (`PFTCatalog_MODIS_UMD`) instead of IGBP.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]

*Created by*
 - skoirala
"""
PFT_forcing_MODIS_UMD
