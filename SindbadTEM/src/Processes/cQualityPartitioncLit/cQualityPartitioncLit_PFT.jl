export cQualityPartitioncLit_PFT

"""
    FRAC_LIGNIN_STRUCT_PER_PFT

Lignin as a fraction of structural litter carbon, per canonical PFT
(`PFTCatalog_SINDBAD_PFT`) name. Fixed data, not a parameter -- calibration
happens through `frac_lignin_struct_scalar` in `cQualityPartitioncLit_PFT`
instead.

Transcribed from the legacy 12-element `frac_lignin_struct_per_PFT` array
(values `[0.6144, 0.5251, 0.4401, 0.3801, 0.5251, 0.4813, 0.4125, 0.0,
0.4311, 0.4813, 0.4813, 0.4658]`), keyed to `PFTCatalog_MODIS_PFT` position
order (array position `i` = code `i - 1`). See `LIT_FRAC_LIGNIN_PER_PFT` in
`vegQualityTraits_CASA.jl` for the full source-position and gap-fill
convention this follows; `Croplands` here is 0.4311 from position 9
(`Broadleaf_Croplands`), with position 8 (`Cereal_Croplands`, 0.0) dropped
once both collapse onto IGBP's single `Croplands` class.
"""
const FRAC_LIGNIN_STRUCT_PER_PFT = (;
    Evergreen_Needleleaf_Forests = 0.5251,
    Evergreen_Broadleaf_Forests = 0.4401,
    Deciduous_Needleleaf_Forests = 0.3801,
    Deciduous_Broadleaf_Forests = 0.5251,
    Mixed_Forests = 0.5251,
    Closed_Shrublands = 0.4813,
    Open_Shrublands = 0.4813,
    Woody_Savannas = 0.4125,
    Savannas = 0.4125,
    Grasslands = 0.4125,
    Permanent_Wetlands = 0.4125,
    Croplands = 0.4311,
    Urban_and_Built_up_Lands = 0.4813,
    Cropland_Natural_Vegetation_Mosaics = 0.4311,
    Permanent_Snow_and_Ice = 0.4813,
    Barren = 0.4658,
    Water_Bodies = 0.6144,
    Unclassified = 0.4658,
)

"""
    FRAC_LIGNIN_WOOD_PER_PFT

Lignin fraction of woody litter, per canonical PFT (`PFTCatalog_SINDBAD_PFT`)
name. Fixed data, not a parameter -- calibration happens through
`frac_lignin_wood_scalar` in `cQualityPartitioncLit_PFT` instead.

Transcribed from the legacy 12-element `frac_lignin_wood_per_PFT` array
(values `[0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.0, 0.4, 0.4, 0.4, 0.4]`),
uniformly 0.4 except position 8 (`Cereal_Croplands`, 0.0, dropped once
collapsed onto IGBP's `Croplands` alongside position 9's 0.4).
"""
const FRAC_LIGNIN_WOOD_PER_PFT = (;
    Evergreen_Needleleaf_Forests = 0.4,
    Evergreen_Broadleaf_Forests = 0.4,
    Deciduous_Needleleaf_Forests = 0.4,
    Deciduous_Broadleaf_Forests = 0.4,
    Mixed_Forests = 0.4,
    Closed_Shrublands = 0.4,
    Open_Shrublands = 0.4,
    Woody_Savannas = 0.4,
    Savannas = 0.4,
    Grasslands = 0.4,
    Permanent_Wetlands = 0.4,
    Croplands = 0.4,
    Urban_and_Built_up_Lands = 0.4,
    Cropland_Natural_Vegetation_Mosaics = 0.4,
    Permanent_Snow_and_Ice = 0.4,
    Barren = 0.4,
    Water_Bodies = 0.4,
    Unclassified = 0.4,
)

#! format: off
@bounds @describe @units @timescale @with_kw struct cQualityPartitioncLit_PFT{T1,T2} <: cQualityPartitioncLit
    frac_lignin_struct_scalar::T1 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT lignin fraction of structural litter" | "-" | ""
    frac_lignin_wood_scalar::T2 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT lignin fraction of woody litter" | "-" | ""
end
#! format: on

function define(params::cQualityPartitioncLit_PFT, forcing, land, helpers)
    @unpack_nt begin
        c_taker ⇐ land.cCycleBase
        cEco ⇐ land.pools
    end

    # One value per active carbon transfer, neutral so that every flow this process
    # does not own leaves the partition to the other factors.
    c_flow_QP_f_cLit = getVectorOfType(cEco, length(c_taker), one)

    @pack_nt c_flow_QP_f_cLit ⇒ land.diagnostics
    return land
end

function precompute(params::cQualityPartitioncLit_PFT, forcing, land, helpers)
    ## unpack parameters
    @unpack_cQualityPartitioncLit_PFT params

    ## unpack land variables
    @unpack_nt begin
        c_flow_QP_f_cLit ⇐ land.diagnostics
        c_flow_named_edges ⇐ land.cCycleBase
        PFT ⇐ land.states
        o_one ⇐ land.constants
    end

    ## calculate variables
    # Selected by the canonical PFT name in land.states.PFT, rather than a
    # positional index into an array tied to one specific classification.
    # The per-PFT tables are plain Float64 literals; oftype matches each
    # looked-up value to its scalar's type before multiplying, so the result
    # stays the parameter type instead of silently widening to Float64.
    frac_lignin_struct = oftype(frac_lignin_struct_scalar, getproperty(FRAC_LIGNIN_STRUCT_PER_PFT, PFT)) * frac_lignin_struct_scalar
    frac_lignin_wood = oftype(frac_lignin_wood_scalar, getproperty(FRAC_LIGNIN_WOOD_PER_PFT, PFT)) * frac_lignin_wood_scalar

    for (stabilized_edge, microbial_edge) ∈ QP_CLIT_STRUCT_GROUPS
        c_flow_QP_f_cLit = setQPGroup(c_flow_QP_f_cLit, c_flow_named_edges,
            (stabilized_edge, microbial_edge),
            (frac_lignin_struct, o_one - frac_lignin_struct))
    end
    for (stabilized_edge, microbial_edge) ∈ QP_CLIT_WOOD_GROUPS
        c_flow_QP_f_cLit = setQPGroup(c_flow_QP_f_cLit, c_flow_named_edges,
            (stabilized_edge, microbial_edge),
            (frac_lignin_wood, o_one - frac_lignin_wood))
    end

    ## pack land variables
    @pack_nt c_flow_QP_f_cLit ⇒ land.diagnostics
    return land
end

purpose(::Type{cQualityPartitioncLit_PFT}) = "Lignin control of the carbon-quality partition looked up per PFT class, separately for structural and woody litter."

@doc """

	$(getModelDocString(cQualityPartitioncLit_PFT))

---

# Extended help

Kept as a legacy alternative to [`cQualityPartitioncLit_vegQualityTraits`](@ref),
to be revisited later. The approach selects `FRAC_LIGNIN_STRUCT_PER_PFT` and
`FRAC_LIGNIN_WOOD_PER_PFT` for the canonical PFT name in `land.states.PFT`,
scales each by its bounded scalar (`frac_lignin_struct_scalar`,
`frac_lignin_wood_scalar`, since the per-PFT tables themselves are fixed data
excluded from optimization), and writes each, with its complement, into the
flows of `QP_CLIT_STRUCT_GROUPS` and `QP_CLIT_WOOD_GROUPS`. This table is its
own independent calibration: unlike `cQualityPartitioncLit_vegQualityTraits`,
it does not read `land.properties.lit_frac_lignin_struct`/`lit_frac_lignin_wood`,
so it can silently disagree with whatever `vegQualityTraits` approach is
selected.

The structural defaults are the CASA relation
`clamp_zero_one(lit_frac_lignin * 0.65 * 2.22 / (1 - lit_frac_metabolic))`
evaluated over the per-PFT litter chemistry of `vegQualityTraits_CASA`, so this
approach starts from the values that approach's lignin term produces while
leaving them free to be calibrated on their own. The woody defaults are the
single CASA value, 0.4, which that approach does not resolve per PFT.
`Cereal_Croplands` (position 8 of the legacy arrays these tables were
transcribed from) has no lignin in that chemistry and therefore gets zero in
both -- see `FRAC_LIGNIN_STRUCT_PER_PFT`'s docstring for why that value does
not survive separately once collapsed onto IGBP's single `Croplands` class.

*References*
 - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.

*Versions*
 - 1.0 on 04.09.2026 [skoirala]: as cQualityPartitionLignin_PFT
 - 2.0 on 10.09.2026 [skoirala]: renamed/relocated into cQualityPartitioncLit, kept as legacy
 - 3.0 on 10.09.2026 [skoirala]: per-PFT lookups keyed by canonical PFT name
   (PFTCatalog_SINDBAD_PFT) instead of a positional index; the per-PFT arrays
   became fixed named lookups plus bounded scalar multipliers, since
   array-valued struct fields cannot be optimized

*Created by*
 - skoirala

"""
cQualityPartitioncLit_PFT
