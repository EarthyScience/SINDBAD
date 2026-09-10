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
