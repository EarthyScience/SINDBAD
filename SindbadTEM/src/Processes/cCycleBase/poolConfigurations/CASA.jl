export CarbonPoolsCASA

struct CarbonPoolsCASA <: CarbonPoolConfiguration end
purpose(::Type{CarbonPoolsCASA}) = "CASA carbon pools: 14 pools, vegetation split into fine and coarse roots and litter nested by organ"

"""
    poolStructure(::Type{CarbonPoolsCASA})

Fourteen pools on a nested layout: roots split into fine and coarse, litter nested by
organ and then by quality, and an explicit microbial component.

# Notes:
- The nesting generates `cVegRoot`, `cLitLeaf`, `cLitRoot` and `cLitRootFine` without
  declaring them, giving a `cEco` of `cVegRootFine`, `cVegRootCoarse`, `cVegWood`,
  `cVegLeaf`, `cLitLeafFast`, `cLitLeafSlow`, `cLitRootFineFast`,
  `cLitRootFineSlow`, `cLitRootCoarse`, `cLitWood`, `cMicSurf`, `cMicSoil`,
  `cSoilSlow`, `cSoilOld`.
- Fine-root litter carries the quality split and coarse-root litter does not, so
  `cLitRoot` nests one level deeper than the other organs.
- Litter nests by organ, so the fast/slow quality split cuts across the hierarchy and
  cannot be a nesting level. It is declared as `poolAliases` instead, the only
  configuration that needs any.
- See `poolStructure(::Type{CarbonPoolsGSI})` for the shape and ordering rules that
  apply to every structure.
"""
poolStructure(::Type{CarbonPoolsCASA}) = (;
    combine = :cEco,
    components = (;
        cVeg  = (; Root = (; Fine = (1, 25.0), Coarse = (1, 25.0)),
                   Wood = (1, 25.0), Leaf = (1, 25.0)),
        cLit  = (; Leaf = (; Fast = (1, 25.0), Slow = (1, 25.0)),
                   Root = (; Fine = 
                                (; Fast = (1, 25.0), Slow = (1, 25.0)),
                             Coarse = (1, 25.0)),
                   Wood = (1, 100.0)),
        cMic  = (; Surf = (1, 20.0), Soil = (1, 20.0)),
        cSoil = (; Slow = (1, 500.0), Old = (1, 1000.0)),
    ),
)

"""
    poolAliases(::Type{CarbonPoolsCASA})

The fast/slow litter grouping, which this structure's nesting cannot produce.

# Notes:
- CASA litter is nested by organ, while the fast/slow axis is quality, so that split
  cannot be a nesting level. These two entries are the only groupings in any
  configuration that cut across the hierarchy.
- An alias has no backing array in `land.pools`, so models must iterate
  `helpers.pools.zix.X` for these names rather than reach into `land.pools.X`.
"""
poolAliases(::Type{CarbonPoolsCASA}) = (;
    cLitFast = (:cLitLeafFast, :cLitRootFineFast),                            # -> (5, 7)
    cLitSlow = (:cLitLeafSlow, :cLitRootFineSlow, :cLitRootCoarse, :cLitWood), # -> (6, 8, 9, 10)
)

"""
    CASA_FLOW_EDGES

The 22 edges of `cCycleBase_CASA`, transcribed from its 14x14 `c_flow_A_array`.
The pool names differ from the ones that matrix was written in, and so does the index
order, which a name-keyed edge list does not care about: the edges are the same 22
links.

Lives here rather than with the approaches because every name in it is a pool of this
structure and the list resolves against no other. See `cFlowEdges` for the ordering
convention and why edges must name leaf pools.

# Notes:
- The 16 decomposition edges (everything leaving a litter, microbial or soil pool)
  carry a `(giver => taker, value)` microbial-efficiency default instead of a plain
  pair, so `cFlowStructure` starts `c_flow_ME_vec` at the CASA table's own values
  rather than the neutral one every other structure gets. The 6 vegetation-to-litter
  edges are litterfall, not decomposition, and stay plain pairs. The values match
  `cMicrobialEfficiency_CASA`'s parameter defaults (`eff_cLit_to_cMicSurf`,
  `eff_cSoil_to_cMicSoil`, and so on), which is what selecting that approach, or
  `cMicrobialEfficiency_CASApool`, still reproduces.
- `cMicSoil_to_cSoilSlow` and `cMicSoil_to_cSoilOld` are the one pathway whose real
  value is texture-driven (`meTextureEfficiency`, from `st_clay`/`st_silt`), which
  needs runtime data this declaration does not have. Their `0.45` here is a static
  fallback, matching the other soil-group constants, not the texture response;
  `cMicrobialEfficiency_CASA` and `cMicrobialEfficiency_CASApool` both overwrite it
  with the real value when selected.
"""
const CASA_FLOW_EDGES = (                    # giver => taker, in flow-vector order
    :cVegRootFine     => :cLitRootFineFast,                                  # giver 1
    :cVegRootFine     => :cLitRootFineSlow,
    :cVegRootCoarse   => :cLitRootCoarse,                                    # giver 2
    :cVegWood         => :cLitWood,                                          # giver 3
    :cVegLeaf         => :cLitLeafFast,     :cVegLeaf         => :cLitLeafSlow,   # giver 4
    (:cLitLeafFast     => :cMicSurf, 0.4),                                    # giver 5
    (:cLitLeafSlow     => :cMicSurf, 0.4),  (:cLitLeafSlow     => :cSoilSlow, 0.6),  # giver 6
    (:cLitRootFineFast => :cMicSoil, 0.45),                                   # giver 7
    (:cLitRootFineSlow => :cMicSoil, 0.45), (:cLitRootFineSlow => :cSoilSlow, 0.55), # giver 8
    (:cLitRootCoarse   => :cMicSoil, 0.4),  (:cLitRootCoarse   => :cSoilSlow, 0.6),  # giver 9
    (:cLitWood         => :cMicSurf, 0.4),  (:cLitWood         => :cSoilSlow, 0.6),  # giver 10
    (:cMicSurf         => :cSoilSlow, 0.4),                                   # giver 11
    (:cMicSoil         => :cSoilSlow, 0.45), (:cMicSoil        => :cSoilOld, 0.45),  # giver 12
    (:cSoilSlow        => :cMicSoil, 0.45), (:cSoilSlow        => :cSoilOld, 0.45),  # giver 13
    (:cSoilOld         => :cMicSoil, 0.45),                                   # giver 14
)
