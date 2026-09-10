export vegQualityTraits_CASA

"""
    LIT_FRAC_LIGNIN_PER_PFT

Lignin fraction of litter, per canonical PFT (`PFTCatalog_SINDBAD_PFT`) name.
Fixed data, not a parameter -- calibration happens through
`lit_frac_lignin_scalar` in `vegQualityTraits_CASA` instead.

Transcribed from the legacy 12-element `lit_frac_lignin_per_PFT` array (values
`[0.2, 0.2, 0.22, 0.25, 0.2, 0.15, 0.1, 0.0, 0.2, 0.15, 0.15, 0.1]`), which was
keyed to `PFTCatalog_MODIS_PFT` position order (array position `i` = code
`i - 1`). Each entry below cites the source position it came from; entries
citing another canonical name's value are IGBP classes with no counterpart in
the 12-class source and are filled via the same judgment calls documented in
`pftClasses(::Type{PFTCatalog_MODIS_PFT})` -- placeholders to confirm, not
calibrated values in their own right:

- `Evergreen_Needleleaf_Forests`..`Deciduous_Broadleaf_Forests`,
  `Open_Shrublands`, `Grasslands`, `Urban_and_Built_up_Lands`,
  `Permanent_Snow_and_Ice`, `Barren`, `Water_Bodies`: direct, from source
  positions 2, 3, 4, 5, 6, 7, 10, 11, 12, 1 respectively.
- `Croplands`: from position 9 (`Broadleaf_Croplands`, 0.2). Position 8
  (`Cereal_Croplands`, 0.0 -- the "no lignin" class the original docstring
  referenced) has no separate representation once both collapse onto IGBP's
  one `Croplands` class, and is dropped here.
- `Mixed_Forests`: `Deciduous_Broadleaf_Forests`'s value.
- `Closed_Shrublands`: `Open_Shrublands`'s value.
- `Woody_Savannas`, `Savannas`, `Permanent_Wetlands`: `Grasslands`'s value.
- `Cropland_Natural_Vegetation_Mosaics`: `Croplands`'s value.
- `Unclassified`: `Barren`'s value, a defensive default for missing/QA-flagged
  pixels rather than a scientific claim.
"""
const LIT_FRAC_LIGNIN_PER_PFT = (;
    Evergreen_Needleleaf_Forests = 0.2,
    Evergreen_Broadleaf_Forests = 0.22,
    Deciduous_Needleleaf_Forests = 0.25,
    Deciduous_Broadleaf_Forests = 0.2,
    Mixed_Forests = 0.2,
    Closed_Shrublands = 0.15,
    Open_Shrublands = 0.15,
    Woody_Savannas = 0.1,
    Savannas = 0.1,
    Grasslands = 0.1,
    Permanent_Wetlands = 0.1,
    Croplands = 0.2,
    Urban_and_Built_up_Lands = 0.15,
    Cropland_Natural_Vegetation_Mosaics = 0.2,
    Permanent_Snow_and_Ice = 0.15,
    Barren = 0.1,
    Water_Bodies = 0.2,
    Unclassified = 0.1,
)

"""
    LIT_C_TO_N_PER_PFT

Carbon-to-nitrogen ratio of litter, per canonical PFT (`PFTCatalog_SINDBAD_PFT`)
name. Fixed data, not a parameter -- calibration happens through
`lit_C_to_N_scalar` in `vegQualityTraits_CASA` instead.

Transcribed the same way as `LIT_FRAC_LIGNIN_PER_PFT` from the legacy
`lit_C_to_N_per_PFT` array (values
`[40.0, 50.0, 65.0, 80.0, 50.0, 50.0, 50.0, 0.0, 65.0, 50.0, 50.0, 40.0]`);
see that constant's docstring for the source-position and gap-fill notes,
which apply identically here (position 8, `Cereal_Croplands` = 0.0, is
likewise dropped once collapsed onto `Croplands`).
"""
const LIT_C_TO_N_PER_PFT = (;
    Evergreen_Needleleaf_Forests = 50.0,
    Evergreen_Broadleaf_Forests = 65.0,
    Deciduous_Needleleaf_Forests = 80.0,
    Deciduous_Broadleaf_Forests = 50.0,
    Mixed_Forests = 50.0,
    Closed_Shrublands = 50.0,
    Open_Shrublands = 50.0,
    Woody_Savannas = 50.0,
    Savannas = 50.0,
    Grasslands = 50.0,
    Permanent_Wetlands = 50.0,
    Croplands = 65.0,
    Urban_and_Built_up_Lands = 50.0,
    Cropland_Natural_Vegetation_Mosaics = 65.0,
    Permanent_Snow_and_Ice = 50.0,
    Barren = 40.0,
    Water_Bodies = 40.0,
    Unclassified = 40.0,
)

#! format: off
@bounds @describe @units @timescale @with_kw struct vegQualityTraits_CASA{T1,T2,T3,T4,T5,T6,T7,T8} <: vegQualityTraits
    lit_frac_metabolic_A::T1 = 0.85 | (0.0, 1.0) | "intercept of the metabolic litter fraction at zero lignin-to-nitrogen ratio" | "fraction" | ""
    lit_frac_metabolic_B::T2 = 0.018 | (0.0, 0.1) | "sensitivity of the metabolic litter fraction to the lignin-to-nitrogen ratio" | "fraction" | ""
    lit_nonsol_to_sol_lignin::T3 = 2.22 | (1.0, 5.0) | "scalar converting nonsoluble to soluble lignin" | "fraction" | ""
    lit_frac_lignin_scalar::T4 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT lignin fraction of litter" | "-" | ""
    lit_C_to_N_scalar::T5 = 1.0 | (0.25, 4.0) | "scalar for the per-PFT carbon-to-nitrogen ratio of litter" | "-" | ""
    lit_frac_C_lignin::T6 = 0.65 | (0.0, 1.0) | "carbon fraction of lignin" | "fraction" | ""
    lit_k_f_lignin_A::T7 = 3.0 | (0.0, 10.0) | "sensitivity of the structural litter decomposition rate to the structural lignin fraction" | "" | ""
    lit_frac_lignin_wood::T8 = 0.4 | (0.0, 1.0) | "lignin fraction of woody litter" | "fraction" | ""
end
#! format: on

function precompute(params::vegQualityTraits_CASA, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegQualityTraits_CASA params

    ## unpack land variables
    @unpack_nt begin
        PFT ⇐ land.states
        o_one ⇐ land.constants
    end

    ## calculate variables
    # Select the litter chemistry of the canonical PFT class of this pixel,
    # by name rather than by a positional index into an array. The per-PFT
    # tables are plain Float64 literals; oftype matches each looked-up value
    # to its scalar's type before multiplying, so the result stays the
    # parameter type instead of silently widening to Float64.
    lit_C_to_N = oftype(lit_C_to_N_scalar, getproperty(LIT_C_TO_N_PER_PFT, PFT)) * lit_C_to_N_scalar
    lit_frac_lignin = oftype(lit_frac_lignin_scalar, getproperty(LIT_FRAC_LIGNIN_PER_PFT, PFT)) * lit_frac_lignin_scalar

    # lignin-to-nitrogen ratio of litter
    lignin_to_N = (lit_C_to_N * lit_frac_lignin) * lit_nonsol_to_sol_lignin

    # the metabolic fraction of litter decreases linearly with the
    # lignin-to-nitrogen ratio
    lit_frac_metabolic = clamp_zero_one(lit_frac_metabolic_A - lit_frac_metabolic_B * lignin_to_N)

    # lignin is present only in the structural litter fraction, so the lignin
    # content of litter is rescaled by the structural fraction of litter,
    # 1 - lit_frac_metabolic
    lit_frac_lignin_struct = clamp_zero_one(
        (lit_frac_lignin * lit_frac_C_lignin * lit_nonsol_to_sol_lignin) /
        (o_one - lit_frac_metabolic))

    # effect of lignin content on the decomposition rate of the structural
    # litter pools
    lit_k_f_lignin = exp(-lit_k_f_lignin_A * lit_frac_lignin_struct)

    ## pack land variables
    @pack_nt begin
        (lit_C_to_N, lit_frac_lignin, lit_frac_metabolic, lit_nonsol_to_sol_lignin) ⇒ land.properties
        (lit_frac_C_lignin, lit_frac_lignin_struct, lit_frac_lignin_wood, lit_k_f_lignin) ⇒ land.properties
    end
    return land
end

purpose(::Type{vegQualityTraits_CASA}) = "Metabolic litter fraction and the structural lignin fraction, with PFT-dependent litter chemistry, and the lignin effect on decomposition rate, as modeled in CASA."

@doc """

	$(getModelDocString(vegQualityTraits_CASA))

---

# Extended help

The approach looks up the lignin fraction and the carbon-to-nitrogen ratio of
litter for the canonical PFT name in `land.states.PFT` (`LIT_FRAC_LIGNIN_PER_PFT`,
`LIT_C_TO_N_PER_PFT`), each scaled by a bounded, optimizable multiplier
(`lit_frac_lignin_scalar`, `lit_C_to_N_scalar`) since the per-PFT tables
themselves are fixed data excluded from optimization, forms the
lignin-to-nitrogen ratio

`lignin_to_N = lit_C_to_N * lit_frac_lignin * lit_nonsol_to_sol_lignin`

and computes

`lit_frac_metabolic = clamp_zero_one(lit_frac_metabolic_A - lit_frac_metabolic_B * lignin_to_N)`

Lignin-rich, nitrogen-poor litter therefore yields a smaller metabolic fraction
and a larger structural fraction. Lignin is present only in that structural
fraction, so it is rescaled by `1 - lit_frac_metabolic` to give the structural
lignin fraction:

`lit_frac_lignin_struct = clamp_zero_one(lit_frac_lignin * lit_frac_C_lignin * lit_nonsol_to_sol_lignin / (1 - lit_frac_metabolic))`

`lit_k_f_lignin = exp(-lit_k_f_lignin_A * lit_frac_lignin_struct)`

This used to be two approaches, `metabolicFraction_CASA` and `lignin_CASA`, with the
second reading the first's output back from `land.properties`. Merged into one so the
per-PFT litter chemistry and the lignin effect it drives are always computed
consistently, with no dependency on a matching separate selection.

This replaces the metabolic-fraction and lignin parts of the legacy
`cTauVegProperties_CASA`, where `MTF` was clipped with a MATLAB-style logical index
that never ran in Julia; `clamp_zero_one` also bounds the fraction above, which the
original did not.

*References*
 - Carvalhais, N., Reichstein, M., Seixas, J., Collatz, G. J., Pereira, J. S., Berbigier, P., & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for biogeochemical modeling performance and inverse parameter retrieval. Global Biogeochemical Cycles, 22(2).
 - Potter, C. S., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003). Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data and ecosystem modeling 1982-1998. Global and Planetary Change, 39(3-4), 201-213.
 - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.

*Versions*
 - 1.0 on 04.09.2026 [skoirala]: extracted from cTauVegProperties_CASA, as separate metabolicFraction_CASA and lignin_CASA approaches
 - 2.0 on 09.09.2026 [skoirala]: merged metabolicFraction_CASA and lignin_CASA into vegQualityTraits_CASA
 - 3.0 on 10.09.2026 [skoirala]: per-PFT litter chemistry keyed by canonical
   PFT name (PFTCatalog_SINDBAD_PFT) instead of a positional index into an
   array tied to one specific classification; the two per-PFT arrays became
   fixed named lookups plus bounded scalar multipliers, since array-valued
   struct fields cannot be optimized

*Created by*
 - ncarvalhais

"""
vegQualityTraits_CASA
