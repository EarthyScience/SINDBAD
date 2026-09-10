export cQualityPartitioncMic
export QP_CMIC_GROUPS

abstract type cQualityPartitioncMic <: LandEcosystem end

purpose(::Type{cQualityPartitioncMic}) = "Effect of soil texture on the carbon-quality partition: the split of soil-microbial decomposition between stabilization into old soil carbon and the remaining pathway."

"""
    QP_CMIC_GROUPS

The partition group this process owns, as a `(stabilized edge, other edge)` pair.
The first edge takes the fraction stabilized into old soil carbon and the second
takes its complement.

This is the complete set of outgoing flows of `cMicSoil`, and no other
`cQualityPartition` factor process touches it, which is what lets the factors be
multiplied into `c_flow_QP_vec`. `cMicSurf_to_cSoilSlow` is single-outflow and is
not listed here: it already keeps the neutral partition of one.
"""
const QP_CMIC_GROUPS = ((:cMicSoil_to_cSoilOld, :cMicSoil_to_cSoilSlow),)

includeApproaches(cQualityPartitioncMic, @__DIR__)

@doc """
	$(getModelDocString(cQualityPartitioncMic))

---
# Extended help

`cQualityPartitioncMic` provides `c_flow_QP_f_cMic`, a flow-aligned factor of the
carbon-quality partition with one entry per active carbon transfer, in the same
order as `c_flow_order`, `c_giver` and `c_taker`.

The factor is one everywhere except on the flows leaving `cMicSoil`, listed in
`QP_CMIC_GROUPS`: clay-rich soils stabilize a larger share of decomposing
soil-microbial carbon into the old soil pool. [`cQualityPartition_mult`](@ref)
multiplies this factor with the `cVeg`, `cLit` and `cSoil` factors to form
`c_flow_QP_vec`.

Edges are matched by pool-name pair through `c_flow_named_edges`, so a structure
without an explicit microbial pool simply keeps its neutral partition of one on
those flows.

Named after the giver pool group it owns (`cMic`), the way
[`cMicrobialEfficiencycLit`](@ref)/`cMic`/`cSoil` are. This and
[`cQualityPartitioncSoil`](@ref) used to be combined into one process,
`cQualityPartitionSoilProperties`, which mixed the `cSoilSlow` and `cMicSoil`
giver groups; splitting them apart keeps every `cQualityPartition` factor
strictly single-giver-group, as `cMicrobialEfficiency`'s already are.

This is the partition counterpart of [`cTauSoilProperties`](@ref) and
[`cMicrobialEfficiencycMic`](@ref), which carry the texture control of
decomposition rates and of microbial transfer efficiency respectively.
"""
cQualityPartitioncMic
