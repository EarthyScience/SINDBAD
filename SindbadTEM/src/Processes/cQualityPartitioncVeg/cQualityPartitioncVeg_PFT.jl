export cQualityPartitioncVeg_PFT

"""
    FRAC_METABOLIC_PER_PFT

Fraction of leaf and fine-root litterfall routed to the metabolic litter
pools, per canonical PFT (`PFTCatalog_SINDBAD_PFT`) name. Fixed data, not a
parameter -- calibration happens through `frac_metabolic_scalar` in
`cQualityPartitioncVeg_PFT` instead.

Transcribed from the legacy 12-element `frac_metabolic_per_PFT` array (values
`[0.5303, 0.4504, 0.2786, 0.0508, 0.4504, 0.5503, 0.6502, 0.85, 0.3305,
0.5503, 0.5503, 0.6902]`), keyed to `PFTCatalog_MODIS_PFT` position order
(array position `i` = code `i - 1`). See
`LIT_FRAC_LIGNIN_PER_PFT` in `vegQualityTraits_CASA.jl` for the full
source-position and gap-fill convention this follows; the one difference
here is `Croplands`, at 0.3305 from position 9 (`Broadleaf_Croplands`) --
position 8 (`Cereal_Croplands`, 0.85, the class this approach's docstring
calls out as having "no lignin," hence the CASA-relation intercept) is
dropped once both collapse onto IGBP's single `Croplands` class.
"""
const FRAC_METABOLIC_PER_PFT = (;
    Evergreen_Needleleaf_Forests = 0.4504,
    Evergreen_Broadleaf_Forests = 0.2786,
    Deciduous_Needleleaf_Forests = 0.0508,
    Deciduous_Broadleaf_Forests = 0.4504,
    Mixed_Forests = 0.4504,
    Closed_Shrublands = 0.5503,
    Open_Shrublands = 0.5503,
    Woody_Savannas = 0.6502,
    Savannas = 0.6502,
    Grasslands = 0.6502,
    Permanent_Wetlands = 0.6502,
    Croplands = 0.3305,
    Urban_and_Built_up_Lands = 0.5503,
    Cropland_Natural_Vegetation_Mosaics = 0.3305,
    Permanent_Snow_and_Ice = 0.5503,
    Barren = 0.6902,
    Water_Bodies = 0.5303,
    Unclassified = 0.6902,
)

#! format: off
@bounds @describe @units @timescale @with_kw struct cQualityPartitioncVeg_PFT{T1} <: cQualityPartitioncVeg
    frac_metabolic_scalar::T1 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT metabolic litter fraction" | "-" | ""
end
#! format: on

function define(params::cQualityPartitioncVeg_PFT, forcing, land, helpers)
    @unpack_nt begin
        c_taker ⇐ land.cCycleBase
        cEco ⇐ land.pools
    end

    # One value per active carbon transfer, neutral so that every flow this process
    # does not own leaves the partition to the other factors.
    c_flow_QP_f_cVeg = getVectorOfType(cEco, length(c_taker), one)

    @pack_nt c_flow_QP_f_cVeg ⇒ land.diagnostics
    return land
end

function precompute(params::cQualityPartitioncVeg_PFT, forcing, land, helpers)
    ## unpack parameters
    @unpack_cQualityPartitioncVeg_PFT params

    ## unpack land variables
    @unpack_nt begin
        c_flow_QP_f_cVeg ⇐ land.diagnostics
        c_flow_named_edges ⇐ land.cCycleBase
        PFT ⇐ land.states
        o_one ⇐ land.constants
    end

    ## calculate variables
    # Selected by the canonical PFT name in land.states.PFT, rather than a
    # positional index into an array tied to one specific classification.
    # FRAC_METABOLIC_PER_PFT is plain Float64 literals; oftype matches the
    # looked-up value to the scalar's type before multiplying, so the result
    # stays the parameter type instead of silently widening to Float64.
    frac_metabolic = oftype(frac_metabolic_scalar, getproperty(FRAC_METABOLIC_PER_PFT, PFT)) * frac_metabolic_scalar

    for (metabolic_edge, structural_edge) ∈ QP_CVEG_GROUPS
        c_flow_QP_f_cVeg = setQPGroup(c_flow_QP_f_cVeg,
            c_flow_named_edges, (metabolic_edge, structural_edge),
            (frac_metabolic, o_one - frac_metabolic))
    end

    ## pack land variables
    @pack_nt c_flow_QP_f_cVeg ⇒ land.diagnostics
    return land
end

purpose(::Type{cQualityPartitioncVeg_PFT}) = "Metabolic litter fraction of the carbon-quality partition looked up per PFT class."

@doc """

	$(getModelDocString(cQualityPartitioncVeg_PFT))

---

# Extended help

Kept as a legacy alternative to [`cQualityPartitioncVeg_vegQualityTraits`](@ref),
to be revisited later. The approach selects `FRAC_METABOLIC_PER_PFT` for the
canonical PFT name in `land.states.PFT`, scales it by the bounded
`frac_metabolic_scalar` (since the per-PFT table itself is fixed data
excluded from optimization), and writes it, with its complement, into the
flows of `QP_CVEG_GROUPS`. This table is its own independent calibration:
unlike `cQualityPartitioncVeg_vegQualityTraits`, it does not read
`land.properties.lit_frac_metabolic`, so it can silently disagree with whatever
`vegQualityTraits` approach is selected.

The defaults are the CASA relation
`clamp_zero_one(0.85 - 0.018 * lit_C_to_N * lit_frac_lignin * 2.22)` evaluated
over the per-PFT litter chemistry of `vegQualityTraits_CASA`, so this approach
starts from the values CASA produces while leaving them free to be calibrated on
their own. `Cereal_Croplands` (position 8 of the legacy array this table was
transcribed from) has no lignin in that chemistry and therefore keeps the
intercept, 0.85 -- see `FRAC_METABOLIC_PER_PFT`'s docstring for why that value
does not survive separately once collapsed onto IGBP's single `Croplands`
class.

*References*
 - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.

*Versions*
 - 1.0 on 04.09.2026 [skoirala]: as cQualityPartitionMetabolicFraction_PFT
 - 2.0 on 10.09.2026 [skoirala]: renamed/relocated into cQualityPartitioncVeg, kept as legacy
 - 3.0 on 10.09.2026 [skoirala]: per-PFT lookup keyed by canonical PFT name
   (PFTCatalog_SINDBAD_PFT) instead of a positional index; the per-PFT array
   became a fixed named lookup plus a bounded scalar multiplier, since
   array-valued struct fields cannot be optimized

*Created by*
 - skoirala

"""
cQualityPartitioncVeg_PFT
