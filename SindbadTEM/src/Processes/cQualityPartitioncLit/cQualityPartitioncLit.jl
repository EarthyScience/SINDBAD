export cQualityPartitioncLit
export QP_CLIT_STRUCT_GROUPS, QP_CLIT_WOOD_GROUPS

abstract type cQualityPartitioncLit <: LandEcosystem end

purpose(::Type{cQualityPartitioncLit}) = "Effect of litter lignin content on the carbon-quality partition: the split of structural and woody litter decomposition between the slow soil pool and the microbial pools."

"""
    QP_CLIT_STRUCT_GROUPS

The structural-litter partition groups this process owns, as
`(stabilized edge, microbial edge)` pairs. The first edge of a pair takes the
lignin fraction of structural litter carbon and the second takes its complement.
"""
const QP_CLIT_STRUCT_GROUPS = (
    (:cLitLeafSlow_to_cSoilSlow, :cLitLeafSlow_to_cMicSurf),
    (:cLitRootFineSlow_to_cSoilSlow, :cLitRootFineSlow_to_cMicSoil),
)

"""
    QP_CLIT_WOOD_GROUPS

The woody-litter partition groups this process owns, in the same
`(stabilized edge, microbial edge)` shape, split by the lignin fraction of woody
litter rather than of structural litter.
"""
const QP_CLIT_WOOD_GROUPS = (
    (:cLitWood_to_cSoilSlow, :cLitWood_to_cMicSurf),
    (:cLitRootCoarse_to_cSoilSlow, :cLitRootCoarse_to_cMicSoil),
)

includeApproaches(cQualityPartitioncLit, @__DIR__)

@doc """
	$(getModelDocString(cQualityPartitioncLit))

---
# Extended help

`cQualityPartitioncLit` provides `c_flow_QP_f_cLit`, a flow-aligned factor of the
carbon-quality partition with one entry per active carbon transfer, in the same
order as `c_flow_order`, `c_giver` and `c_taker`.

The factor is one everywhere except on the flows leaving the structural and woody
litter pools, listed in `QP_CLIT_STRUCT_GROUPS` and `QP_CLIT_WOOD_GROUPS`: the
lignin-rich part of decomposing litter is stabilized directly into the slow soil
pool, and the rest passes through the microbial pools.
[`cQualityPartition_mult`](@ref) multiplies this factor with the `cVeg`, `cMic`
and `cSoil` factors to form `c_flow_QP_vec`.

Edges are matched by pool-name pair through `c_flow_named_edges`, so a structure
without the explicit structural-litter and microbial pools simply keeps its
neutral partition of one on those flows. `cLitLeafFast_to_cMicSurf` and
`cLitRootFineFast_to_cMicSoil` are single-outflow and are not listed in either
group: they already keep that neutral partition.

Named after the giver pool group it owns (`cLit`), the way
[`cMicrobialEfficiencycLit`](@ref)/`cMic`/`cSoil` are, rather than after the
control it applies (this used to be `cQualityPartitionLignin`).
[`cQualityPartitioncLit_vegQualityTraits`](@ref) reads the lignin fractions
directly from `land.properties`, published by whichever `vegQualityTraits`
approach is selected, so the partition and the decomposition-rate side can never
disagree about them; [`cQualityPartitioncLit_vegTypesLegacy`](@ref) is kept as a legacy,
independently-calibrated alternative.
"""
cQualityPartitioncLit
