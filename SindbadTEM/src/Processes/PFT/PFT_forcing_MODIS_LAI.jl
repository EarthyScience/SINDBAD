export PFT_forcing_MODIS_LAI

struct PFT_forcing_MODIS_LAI <: PFT end

pftCatalog(::Type{PFT_forcing_MODIS_LAI}) = PFTCatalog_MODIS_LAI

function precompute(params::PFT_forcing_MODIS_LAI, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    PFT, PFT_source, PFT_code = resolvePFT(PFTCatalog_MODIS_LAI, f_pft[1])

    ## pack land variables
    @pack_nt (PFT, PFT_source, PFT_code) ⇒ land.states
    return land
end

purpose(::Type{PFT_forcing_MODIS_LAI}) = "Gets the PFT class from LAI/fPAR-biome-classified forcing data."

@doc """

$(getModelDocString(PFT_forcing_MODIS_LAI))

---

# Extended help

Same as [`PFT_forcing_MODIS_IGBP`](@ref), interpreting `f_pft` against the
LAI/fPAR biome legend (`PFTCatalog_MODIS_LAI`) instead of IGBP.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]

*Created by*
 - skoirala
"""
PFT_forcing_MODIS_LAI
