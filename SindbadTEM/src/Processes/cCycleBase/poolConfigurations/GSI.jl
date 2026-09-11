export CarbonPoolsGSI

struct CarbonPoolsGSI <: CarbonPoolConfiguration end
purpose(::Type{CarbonPoolsGSI}) = "GSI carbon pools: 8 pools with a vegetation reserve and litter split into fast and slow"

"""
    poolStructure(::Type{CarbonPoolsGSI})

Eight pools: vegetation split into root, wood, leaf and reserve, litter split by
quality into fast and slow, and soil into slow and old.

# Notes:
- Shaped exactly like the `pools` block of a model structure JSON, so `setPoolsInfo`
  consumes either source with no reshaping.
- Declaration order is `cEco` index order: `getPoolInformation` flattens depth first,
  in declaration order.
- Each leaf is `(number of layers, initial value)`.
- Every nesting level also becomes a real pool, with its own `zix` entry and backing
  array, so `cVeg`, `cLit` and `cSoil` exist without being declared.
- Litter is nested by quality here, so `cLitFast` and `cLitSlow` are generated
  directly and this configuration needs no `poolAliases`.
"""
poolStructure(::Type{CarbonPoolsGSI}) = (;
    combine = :cEco,
    components = (;
        cVeg  = (; Root = (1, 25.0), Wood = (1, 25.0), Leaf = (1, 25.0), Reserve = (1, 10.0)),
        cLit  = (; Fast = (1, 100.0), Slow = (1, 250.0)),
        cSoil = (; Slow = (1, 500.0), Old = (1, 1000.0)),
    ),
)

"""
    GSI_FLOW_EDGES

The 11 edges shared by every GSI-derived base. Transcribed from the `c_flow_A_array`
those approaches carried, which is identical across `cCycleBase_GSI` and
`_GSI_PlantForm`, and the same 11 under `_GSI_PlantForm_MGMT`, whose products are
decay only and so add no edges.

Lives here rather than with the approaches because every name in it is a pool of this
structure and the list resolves against no other. See `cFlowEdges` for the ordering
convention and why edges must name leaf pools.
"""
const GSI_FLOW_EDGES = (            # giver => taker, in flow-vector order
    :cVegRoot    => :cVegReserve,   # giver 1: cVegRoot
    :cVegRoot    => :cLitFast,
    :cVegWood    => :cLitSlow,      # giver 2: cVegWood
    :cVegLeaf    => :cVegReserve,   # giver 3: cVegLeaf
    :cVegLeaf    => :cLitFast,
    :cVegReserve => :cVegRoot,      # giver 4: cVegReserve
    :cVegReserve => :cVegLeaf,
    :cVegReserve => :cLitFast,
    :cLitFast    => :cSoilSlow,     # giver 5: cLitFast
    :cLitSlow    => :cSoilSlow,     # giver 6: cLitSlow
    :cSoilSlow   => :cSoilOld,      # giver 7: cSoilSlow
)

"""
    GSI_TAU_DEFAULT

Turnover *time* (years) of each GSI carbon pool, `tree`-form values -- the base
`cCycleBase_GSI` (no plant-form distinction) reads directly, and every entry of
`GSI_TAU_PLANTFORM` builds on by overriding only what that plant form actually
changes. `k = 1.0/turnover_time` is computed at the point of use; fixed data, not
a parameter.

The four vegetation-organ values (`cVegRoot`, `cVegWood`, `cVegLeaf`,
`cVegReserve`) are exactly what `cCycleBase_GSI_PlantForm`'s `c_τ_tree` field
defaulted to before this table existed (already time-valued, no conversion
needed); the litter/soil values are converted from the rate these pools were
previously given directly (`14.8, 3.9, 0.2, 0.0045`) to time (`1.0/value`).

**Formatting convention**: an entry is written as a plain decimal, rounded to
one decimal place, when the turnover *time* itself is `>= 1`, and as `1.0/N`
(`N` the exact original rate, unrounded) when it is `< 1`. `cSoilSlow`'s
reciprocal (`1.0/0.2 = 5.0`) rounds to the same value, so it is unaffected, but
`cSoilOld`'s (`1.0/0.0045 = 222.22222222222223`) is rounded to `222.2` for
readability -- a deliberate, if small, change to the resulting rate (`1/222.2
≈ 0.0045005` vs the original `0.0045`, about `0.01%`), not merely a
representation change, since a plain decimal is being chosen over the exact
reciprocal on purpose.
"""
const GSI_TAU_DEFAULT = (;
    cVegRoot = 1.0, cVegWood = 50.0, cVegLeaf = 1.0, cVegReserve = TAU_DORMANT,
    cLitFast = 1.0/14.8, cLitSlow = 1.0/3.9, cSoilSlow = 5.0, cSoilOld = 222.2,
)

"""
    GSI_TAU_PLANTFORM

`GSI_TAU_DEFAULT`, one variant per `VegTypeCatalog_PlantForm` group (`tree`,
`shrub`, `herb`, `unknown`) -- top-level keys chosen to match
`vegTypeClasses(VegTypeCatalog_PlantForm)`'s own group names exactly, since
`cCycleBase_GSI_PlantForm`'s `precompute` selects an inner table by
`GSI_TAU_PLANTFORM[land.states.veg_type]`, generically, with no hardcoded branch
per group. Adding a `vegTypes` classification with different group names means
adding a matching top-level key here with real, physically meaningful values for
those groups -- nothing in `cCycleBase_GSI_PlantForm`/`_MGMT` needs to change to
support it.

Only the four vegetation-organ pools vary by plant form (litter/soil turnover
doesn't), so each entry below overrides only the fields that actually differ from
`GSI_TAU_DEFAULT` -- `tree` is `GSI_TAU_DEFAULT` itself, `shrub` overrides just
`cVegWood`, `herb` overrides its three non-dormant organs. The vegetation Reserve
pool is `TAU_DORMANT` for every plant form (inherited from `GSI_TAU_DEFAULT`,
never overridden -- the pre-table `c_τ_herb` field's `0.75e11` was already
"effectively dormant" in effect, just a different large number than `c_τ_tree`/
`c_τ_shrub`'s `1.0e11`; both collapse onto the one shared `TAU_DORMANT` value
now, with no meaningful change to the resulting near-zero rate). `unknown` is the
one exception: every field is `TAU_DORMANT`, reproducing today's zero-rate
fallback for a pixel whose vegetation type doesn't resolve to any of the three
real plant forms, and letting `cCycleBase_GSI_PlantForm` drop the separate
`zero_c_τ_pf` fallback machinery it needed when tree/shrub/herb were struct
fields rather than table entries -- `:unknown` is now just another ordinary
lookup, not a special case in code.

`herb`'s three organs are written as `3.0/4.0` rather than plain `0.75`,
following `GSI_TAU_DEFAULT`'s magnitude-based formatting convention (turnover
time `< 1` uses a fraction): `3.0/4.0` is exactly `0.75` in double precision,
not an approximation of it.
"""
const GSI_TAU_PLANTFORM = (;
    tree = GSI_TAU_DEFAULT,
    shrub = (; GSI_TAU_DEFAULT..., cVegWood = 5.0),
    herb = (; GSI_TAU_DEFAULT...,
        cVegRoot = 3.0/4.0, cVegWood = 3.0/4.0,
        cVegLeaf = 3.0/4.0,
    ),
    unknown = (; GSI_TAU_DEFAULT...,
        cVegRoot = TAU_DORMANT, cVegWood = TAU_DORMANT, cVegLeaf = TAU_DORMANT, cVegReserve = TAU_DORMANT,
        cLitFast = TAU_DORMANT, cLitSlow = TAU_DORMANT, cSoilSlow = TAU_DORMANT, cSoilOld = TAU_DORMANT,
    ),
)

"""
    GSI_CN_ratio

Carbon-to-nitrogen ratio of each GSI carbon pool, per pool name. Fixed data, not a
parameter -- calibration happens through `CN_ratio_scalar` in the owning
approach instead. Only the four vegetation pools have a physically meaningful ratio
(the values `cCycleBase_GSI`/`_PlantForm`/`_MGMT`'s `p_C_to_N_cVeg` field already
defaulted to); every other pool is `0.0`, exactly as that vector field was never
read for any pool other than `cVeg`'s.
"""
const GSI_CN_ratio = (;
    cVegRoot = 25.0, cVegWood = 260.0, cVegLeaf = 260.0, cVegReserve = 10.0,
    cLitFast = 0.0, cLitSlow = 0.0, cSoilSlow = 0.0, cSoilOld = 0.0,
)
