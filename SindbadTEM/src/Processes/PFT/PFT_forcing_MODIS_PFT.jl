export PFT_forcing_MODIS_PFT

struct PFT_forcing_MODIS_PFT <: PFT end

pftCatalog(::Type{PFT_forcing_MODIS_PFT}) = PFTCatalog_MODIS_PFT

function precompute(params::PFT_forcing_MODIS_PFT, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_pft ⇐ forcing

    PFT, PFT_source, PFT_code = resolvePFT(PFTCatalog_MODIS_PFT, f_pft[1])

    ## pack land variables
    @pack_nt (PFT, PFT_source, PFT_code) ⇒ land.states
    return land
end

purpose(::Type{PFT_forcing_MODIS_PFT}) = "Gets the PFT class from Plant-Functional-Type-classified (MCD12Q1 Type 5) forcing data."

@doc """

$(getModelDocString(PFT_forcing_MODIS_PFT))

---

# Extended help

Same as [`PFT_forcing_MODIS_IGBP`](@ref), interpreting `f_pft` against the
MODIS PFT legend (`PFTCatalog_MODIS_PFT`, after Bonan (2002)) instead of
IGBP. `PFT` (canonical, `PFTCatalog_SINDBAD_PFT`-keyed) and `PFT_source`
(this legend's own name) generally differ here: see
`pftClasses(::Type{PFTCatalog_MODIS_PFT})` for the
`Shrub`/`Cereal_Croplands`/`Broadleaf_Croplands` classes that collapse onto a
single canonical class.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]

*Created by*
 - skoirala
"""
PFT_forcing_MODIS_PFT
