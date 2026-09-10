export cQualityPartitioncSoil
export QP_CSOIL_GROUPS

abstract type cQualityPartitioncSoil <: LandEcosystem end

purpose(::Type{cQualityPartitioncSoil}) = "Effect of soil texture on the carbon-quality partition: the split of slow-soil decomposition between stabilization into old soil carbon and the remaining pathway."

"""
    QP_CSOIL_GROUPS

The partition group this process owns, as a `(stabilized edge, other edge)` pair.
The first edge takes the fraction stabilized into old soil carbon and the second
takes its complement.

This is the complete set of outgoing flows of `cSoilSlow`, and no other
`cQualityPartition` factor process touches it, which is what lets the factors be
multiplied into `c_flow_QP_vec`. `cSoilOld_to_cMicSoil` is single-outflow and is
not listed here: it already keeps the neutral partition of one.
"""
const QP_CSOIL_GROUPS = ((:cSoilSlow_to_cSoilOld, :cSoilSlow_to_cMicSoil),)

includeApproaches(cQualityPartitioncSoil, @__DIR__)

@doc """
	$(getModelDocString(cQualityPartitioncSoil))

---
# Extended help

`cQualityPartitioncSoil` provides `c_flow_QP_f_cSoil`, a flow-aligned factor of
the carbon-quality partition with one entry per active carbon transfer, in the
same order as `c_flow_order`, `c_giver` and `c_taker`.

The factor is one everywhere except on the flows leaving `cSoilSlow`, listed in
`QP_CSOIL_GROUPS`: clay-rich soils stabilize a larger share of decomposing
slow-soil carbon into the old soil pool. [`cQualityPartition_mult`](@ref)
multiplies this factor with the `cVeg`, `cLit` and `cMic` factors to form
`c_flow_QP_vec`.

Edges are matched by pool-name pair through `c_flow_named_edges`, so a structure
without an explicit old-soil pool simply keeps its neutral partition of one on
those flows.

Named after the giver pool group it owns (`cSoil`), the way
[`cMicrobialEfficiencycLit`](@ref)/`cMic`/`cSoil` are. This and
[`cQualityPartitioncMic`](@ref) used to be combined into one process,
`cQualityPartitionSoilProperties`, which mixed the `cSoilSlow` and `cMicSoil`
giver groups; splitting them apart keeps every `cQualityPartition` factor
strictly single-giver-group, as `cMicrobialEfficiency`'s already are.

This is the partition counterpart of [`cTauSoilProperties`](@ref), which carries
the texture control of decomposition rates.
"""
cQualityPartitioncSoil
