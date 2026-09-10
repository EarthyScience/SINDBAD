export PFT

abstract type PFT <: LandEcosystem end

purpose(::Type{PFT}) = "Plant Functional Type (PFT) classification."

# Catalogs and their crosswalks are included explicitly before the approaches load,
# matching how cCycleBase.jl includes poolConfigurations.jl before its own approaches:
# includeApproaches globs PFT_*.jl in this directory and does not descend, so it skips
# the pftCatalogs/ subfolder.
include("pftCatalogs/pftCatalogs.jl")

"""
    resolvePFT(::Type{Catalog}, PFT_code)

Shared resolution step for every `PFT_forcing_*`/`PFT_constant_*` approach:
resolve one raw numeric class code against the declared source `Catalog`,
returning `(PFT, PFT_source, PFT_code)` where `PFT` is the canonical name
every downstream science approach reads, `PFT_source` is the honest
source-specific name (kept for provenance/output metadata only), and
`PFT_code` is the raw number, unchanged, passed back through.

Errors (via `pftName`) rather than clamps when `PFT_code` is not one of
`Catalog`'s own, so a bad code fails at the point it was produced instead of
silently aliasing to the wrong class further downstream.
"""
function resolvePFT(::Type{Catalog}, PFT_code) where {Catalog <: PFTCatalog}
    PFT_source = pftName(Catalog, PFT_code)
    PFT = pftCanonicalName(Catalog, PFT_code)
    return PFT, PFT_source, PFT_code
end

includeApproaches(PFT, @__DIR__)

@doc """ 
	$(getModelDocString(PFT))
"""
PFT
