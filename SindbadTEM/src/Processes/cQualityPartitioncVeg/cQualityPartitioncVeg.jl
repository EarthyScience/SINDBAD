export cQualityPartitioncVeg
export QP_CVEG_GROUPS

abstract type cQualityPartitioncVeg <: LandEcosystem end

purpose(::Type{cQualityPartitioncVeg}) = "Effect of the metabolic litter fraction on the carbon-quality partition: the split of leaf and fine-root litterfall between the metabolic and structural litter pools."

"""
    QP_CVEG_GROUPS

The partition groups this process owns, as `(metabolic edge, structural edge)`
pairs. The first edge of a pair takes the metabolic fraction and the second takes
its complement.

Each pair is the complete set of outgoing flows of one giver, and no other
`cQualityPartition` factor process touches `cVegLeaf` or `cVegRootFine`, which is
what lets the factors be multiplied into `c_flow_QP_vec`. `cVegWood_to_cLitWood`
and `cVegRootCoarse_to_cLitRootCoarse` are single-outflow and are not listed here:
they already keep the neutral partition of one that `cCycleBase` allocates.
"""
const QP_CVEG_GROUPS = (
    (:cVegLeaf_to_cLitLeafFast, :cVegLeaf_to_cLitLeafSlow),
    (:cVegRootFine_to_cLitRootFineFast, :cVegRootFine_to_cLitRootFineSlow),
)

includeApproaches(cQualityPartitioncVeg, @__DIR__)

@doc """
	$(getModelDocString(cQualityPartitioncVeg))

---
# Extended help

`cQualityPartitioncVeg` provides `c_flow_QP_f_cVeg`, a flow-aligned factor of the
carbon-quality partition with one entry per active carbon transfer, in the same
order as `c_flow_order`, `c_giver` and `c_taker`.

The factor is one everywhere except on the flows leaving `cVegLeaf` and
`cVegRootFine`, listed in `QP_CVEG_GROUPS`: lignin-rich, nitrogen-poor litter
routes less of its litterfall to the fast-cycling metabolic pools and more to the
structural ones. [`cQualityPartition_mult`](@ref) multiplies this factor with the
`cLit`, `cMic` and `cSoil` factors to form `c_flow_QP_vec`.

Edges are matched by pool-name pair through `c_flow_named_edges`, so a structure
without the explicit metabolic/structural litter split simply keeps its neutral
partition of one on those flows.

Named after the giver pool group it owns (`cVeg`), the way
[`cMicrobialEfficiencycLit`](@ref)/`cMic`/`cSoil` are, rather than after the
control it applies (this used to be `cQualityPartitionMetabolicFraction`).
[`cQualityPartitioncVeg_vegQualityTraits`](@ref) reads the metabolic fraction
directly from `land.properties`, published by whichever `vegQualityTraits`
approach is selected, so the partition and the decomposition-rate side can never
disagree about it; [`cQualityPartitioncVeg_vegTypesLegacy`](@ref) is kept as a legacy,
independently-calibrated alternative.
"""
cQualityPartitioncVeg
