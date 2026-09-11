export CarbonPoolsMGMT

struct CarbonPoolsMGMT <: CarbonPoolConfiguration end
purpose(::Type{CarbonPoolsMGMT}) = "GSI carbon pools plus wood and crop product pools for land management, 10 pools"

"""
    poolStructure(::Type{CarbonPoolsMGMT})

The GSI structure plus a `cProducts` component holding harvested wood and crop
carbon, 10 pools in all.

# Notes:
- Built directly on `poolStructure(CarbonPoolsGSI)` (splatted in, both at the top
  level for `combine` and inside `components` for the eight shared pools) rather than
  repeating its leaf entries, so the two structures cannot drift apart on the eight
  pools they share. Declaration order is preserved by the splat, so the two structures
  still agree on every `cEco` index they share -- that is why
  `cCycleBase_GSI_PlantForm_MGMT` reuses `GSI_FLOW_EDGES` unchanged.
- Products are decay only: carbon enters them from management and leaves by turnover,
  with no pool-to-pool transfer, so they add no flow edges.
- See `poolStructure(::Type{CarbonPoolsGSI})` for the shape and ordering rules that
  apply to every structure.
"""
poolStructure(::Type{CarbonPoolsMGMT}) = (;
    poolStructure(CarbonPoolsGSI)...,
    components = (;
        poolStructure(CarbonPoolsGSI).components...,
        cProducts = (; Wood = (1, 20.0), Crop = (1, 20.0)),
    ),
)

"""
    MGMT_TAU

`GSI_TAU_PLANTFORM` (see `GSI.jl`), same `tree`/`shrub`/`herb`/`unknown` group keys,
each inner table extended with `cProductsWood`/`cProductsCrop` entries so this
structure's table covers every pool `poolStructure(CarbonPoolsMGMT)` declares --
mirroring how `poolStructure` itself is built by splatting GSI's, one level deeper
(per plant-form group). `cCycleBase_GSI_PlantForm_MGMT.jl`'s generic turnover loop
reads this table directly, unlike the plain `GSI_TAU_PLANTFORM` the other two GSI-
family approaches use.

`cProductsWood`/`cProductsCrop` get the same turnover time in every group,
including `unknown`: harvested-product decay does not depend on the pixel's
vegetation-type classification, so unlike the other eight pools -- which go fully
dormant (`TAU_DORMANT`) under `unknown` -- already-harvested carbon keeps decaying
regardless. `cCycleBase_GSI_PlantForm_MGMT`'s old `c_τ_cProductsWood`/
`c_τ_cProductsCrop` rate defaults (`0.03`, `1.0` yr⁻¹) invert to
`33.333333333333336` and `1.0`; following `GSI_TAU_DEFAULT`'s magnitude-based
formatting convention
(`poolConfigurations/GSI.jl`, both entries here are `>= 1`, rounded to one decimal
place), `cProductsWood` is stored as `33.3` -- a deliberate, if small, change to the
resulting rate for readability (about `0.1%` off `0.03`), not merely a
representation change; `cProductsCrop`'s `1.0` is unaffected by rounding. That
approach now scales them with `k_c_products_wood_scalar`/`k_c_products_crop_scalar`
instead of bounding the rate directly.
"""
const MGMT_TAU = (;
    tree = (; GSI_TAU_PLANTFORM.tree..., cProductsWood = 33.3, cProductsCrop = 1.0),
    shrub = (; GSI_TAU_PLANTFORM.shrub..., cProductsWood = 33.3, cProductsCrop = 1.0),
    herb = (; GSI_TAU_PLANTFORM.herb..., cProductsWood = 33.3, cProductsCrop = 1.0),
    unknown = (; GSI_TAU_PLANTFORM.unknown..., cProductsWood = 33.3, cProductsCrop = 1.0),
)
