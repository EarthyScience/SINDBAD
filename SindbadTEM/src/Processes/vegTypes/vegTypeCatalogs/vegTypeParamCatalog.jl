export LIT_FRAC_LIGNIN_PER_VEGTYPE
export LIT_C_TO_N_PER_VEGTYPE
export CVEG_ROOTFINE_LEAF_AGE_PER_VEGTYPE
export CVEG_ROOTCOARSE_WOOD_AGE_PER_VEGTYPE



"""
    LIT_FRAC_LIGNIN_PER_VEGTYPE

Lignin fraction of litter, per canonical vegetation type
(`VegTypeCatalog_SINDBAD`) name. Fixed data, not a parameter -- calibration
happens through `lit_frac_lignin_scalar` in `vegQualityTraits_CASA` instead.

Transcribed from the legacy 12-element `lit_frac_lignin_per_PFT` array (values
`[0.2, 0.2, 0.22, 0.25, 0.2, 0.15, 0.1, 0.0, 0.2, 0.15, 0.15, 0.1]`), which was
keyed to `VegTypeCatalog_MODIS_PFT` position order (array position `i` = code
`i - 1`). Each entry below cites the source position it came from; entries
citing another canonical name's value are IGBP classes with no counterpart in
the 12-class source and are filled via the same judgment calls documented in
`vegTypeClasses(::Type{VegTypeCatalog_MODIS_PFT})` -- placeholders to confirm,
not calibrated values in their own right:

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
const LIT_FRAC_LIGNIN_PER_VEGTYPE = (;
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
    LIT_C_TO_N_PER_VEGTYPE

Carbon-to-nitrogen ratio of litter, per canonical vegetation type
(`VegTypeCatalog_SINDBAD`) name. Fixed data, not a parameter -- calibration
happens through `lit_C_to_N_scalar` in `vegQualityTraits_CASA` instead.

Transcribed the same way as `LIT_FRAC_LIGNIN_PER_VEGTYPE` from the legacy
`lit_C_to_N_per_PFT` array (values
`[40.0, 50.0, 65.0, 80.0, 50.0, 50.0, 50.0, 0.0, 65.0, 50.0, 50.0, 40.0]`);
see that constant's docstring for the source-position and gap-fill notes,
which apply identically here (position 8, `Cereal_Croplands` = 0.0, is
likewise dropped once collapsed onto `Croplands`).
"""
const LIT_C_TO_N_PER_VEGTYPE = (;
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

"""
    CVEG_ROOTFINE_LEAF_AGE_PER_VEGTYPE

Mean age of fine roots and of leaves, per canonical vegetation type
(`VegTypeCatalog_SINDBAD`) name -- the legacy `cVegRootFine_age_per_PFT` and
`cVegLeaf_age_per_PFT` arrays were identical, so one table serves both.
Fixed data, not a parameter -- calibration happens through
`cVegRootFine_age_scalar`/`cVegLeaf_age_scalar` in `cCycleBase_CASA` instead.

Transcribed from the legacy 12-element array (values `[1.8, 1.2, 1.2, 5.0,
1.8, 1.0, 1.0, 0.0, 1.0, 2.8, 1.0, 1.0]`), keyed to `VegTypeCatalog_MODIS_PFT`
position order (array position `i` = code `i - 1`). See
`LIT_FRAC_LIGNIN_PER_VEGTYPE` for the full source-position and gap-fill
convention this follows; `Croplands` here is 1.0 from position 9
(`Broadleaf_Croplands`), with position 8 (`Cereal_Croplands`, 0.0) dropped
once both collapse onto IGBP's single `Croplands` class.

These two fields are unused by `cCycleBase_CASA`'s `compute` today (dead
parameters in the original array form too, and still dead after moving here
from `cCycleBase_CASA.jl`); this table only modernizes their representation
and consolidates it with every other per-vegetation-type default, and does
not change model behavior.
"""
const CVEG_ROOTFINE_LEAF_AGE_PER_VEGTYPE = (;
    Evergreen_Needleleaf_Forests = 1.2,
    Evergreen_Broadleaf_Forests = 1.2,
    Deciduous_Needleleaf_Forests = 5.0,
    Deciduous_Broadleaf_Forests = 1.8,
    Mixed_Forests = 1.8,
    Closed_Shrublands = 1.0,
    Open_Shrublands = 1.0,
    Woody_Savannas = 1.0,
    Savannas = 1.0,
    Grasslands = 1.0,
    Permanent_Wetlands = 1.0,
    Croplands = 1.0,
    Urban_and_Built_up_Lands = 2.8,
    Cropland_Natural_Vegetation_Mosaics = 1.0,
    Permanent_Snow_and_Ice = 1.0,
    Barren = 1.0,
    Water_Bodies = 1.8,
    Unclassified = 1.0,
)

"""
    CVEG_ROOTCOARSE_WOOD_AGE_PER_VEGTYPE

Mean age of coarse roots and of wood, per canonical vegetation type
(`VegTypeCatalog_SINDBAD`) name -- the legacy `cVegRootCoarse_age_per_PFT`
and `cVegWood_age_per_PFT` arrays were identical, so one table serves both.
Fixed data, not a parameter -- calibration happens through
`cVegRootCoarse_age_scalar`/`cVegWood_age_scalar` in `cCycleBase_CASA`
instead.

Transcribed the same way as `CVEG_ROOTFINE_LEAF_AGE_PER_VEGTYPE` from the
legacy 12-element array (values `[41.0, 58.0, 58.0, 42.0, 27.0, 25.0, 25.0,
0.0, 5.5, 40.0, 1.0, 40.0]`); see that constant's docstring for the
source-position and gap-fill notes, which apply identically here
(`Croplands` = 5.5 from position 9, position 8 dropped). Also unused by
`compute` today; see the same note there.
"""
const CVEG_ROOTCOARSE_WOOD_AGE_PER_VEGTYPE = (;
    Evergreen_Needleleaf_Forests = 58.0,
    Evergreen_Broadleaf_Forests = 58.0,
    Deciduous_Needleleaf_Forests = 42.0,
    Deciduous_Broadleaf_Forests = 27.0,
    Mixed_Forests = 27.0,
    Closed_Shrublands = 25.0,
    Open_Shrublands = 25.0,
    Woody_Savannas = 25.0,
    Savannas = 25.0,
    Grasslands = 25.0,
    Permanent_Wetlands = 25.0,
    Croplands = 5.5,
    Urban_and_Built_up_Lands = 40.0,
    Cropland_Natural_Vegetation_Mosaics = 5.5,
    Permanent_Snow_and_Ice = 1.0,
    Barren = 40.0,
    Water_Bodies = 41.0,
    Unclassified = 40.0,
)
