export cQualityPartitioncLit_PFT

#! format: off
@bounds @describe @units @timescale @with_kw struct cQualityPartitioncLit_PFT{T1,T2} <: cQualityPartitioncLit
    frac_lignin_struct_per_PFT::T1 = Float64.([0.6144, 0.5251, 0.4401, 0.3801, 0.5251, 0.4813, 0.4125, 0.0, 0.4311, 0.4813, 0.4813, 0.4658]) | (0.0, 1.0) | "lignin as a fraction of structural litter carbon, per PFT class" | "fraction" | ""
    frac_lignin_wood_per_PFT::T2 = Float64.([0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.0, 0.4, 0.4, 0.4, 0.4]) | (0.0, 1.0) | "lignin fraction of woody litter, per PFT class" | "fraction" | ""
end
#! format: on

function define(params::cQualityPartitioncLit_PFT, forcing, land, helpers)
    @unpack_nt begin
        c_taker ⇐ land.cCycleBase
        cEco ⇐ land.pools
    end

    # One value per active carbon transfer, neutral so that every flow this process
    # does not own leaves the partition to the other factors.
    c_flow_QP_f_cLit = getVectorOfType(cEco, length(c_taker), one)

    @pack_nt c_flow_QP_f_cLit ⇒ land.diagnostics
    return land
end

function precompute(params::cQualityPartitioncLit_PFT, forcing, land, helpers)
    ## unpack parameters
    @unpack_cQualityPartitioncLit_PFT params

    ## unpack land variables
    @unpack_nt begin
        c_flow_QP_f_cLit ⇐ land.diagnostics
        c_flow_named_edges ⇐ land.cCycleBase
        PFT ⇐ land.states
        o_one ⇐ land.constants
    end

    ## calculate variables
    # PFT is a one-based class index, so it is clamped to the length of the per-PFT
    # vectors rather than trusted blindly, as in metabolicFraction_CASA.
    ipft = clamp(round(Int, PFT), 1, length(frac_lignin_struct_per_PFT))
    frac_lignin_struct = frac_lignin_struct_per_PFT[ipft]
    frac_lignin_wood = frac_lignin_wood_per_PFT[ipft]

    for (stabilized_edge, microbial_edge) ∈ QP_CLIT_STRUCT_GROUPS
        c_flow_QP_f_cLit = setQPGroup(c_flow_QP_f_cLit, c_flow_named_edges,
            (stabilized_edge, microbial_edge),
            (frac_lignin_struct, o_one - frac_lignin_struct))
    end
    for (stabilized_edge, microbial_edge) ∈ QP_CLIT_WOOD_GROUPS
        c_flow_QP_f_cLit = setQPGroup(c_flow_QP_f_cLit, c_flow_named_edges,
            (stabilized_edge, microbial_edge),
            (frac_lignin_wood, o_one - frac_lignin_wood))
    end

    ## pack land variables
    @pack_nt c_flow_QP_f_cLit ⇒ land.diagnostics
    return land
end

purpose(::Type{cQualityPartitioncLit_PFT}) = "Lignin control of the carbon-quality partition looked up per PFT class, separately for structural and woody litter."

@doc """

	$(getModelDocString(cQualityPartitioncLit_PFT))

---

# Extended help

Kept as a legacy alternative to [`cQualityPartitioncLit_vegQualityTraits`](@ref),
to be revisited later. The approach selects `frac_lignin_struct_per_PFT` and
`frac_lignin_wood_per_PFT` for the PFT class in `land.states.PFT` and writes each,
with its complement, into the flows of `QP_CLIT_STRUCT_GROUPS` and
`QP_CLIT_WOOD_GROUPS`. This table is its own independent calibration: unlike
`cQualityPartitioncLit_vegQualityTraits`, it does not read
`land.properties.lit_frac_lignin_struct`/`lit_frac_lignin_wood`, so it can
silently disagree with whatever `vegQualityTraits` approach is selected.

The structural defaults are the CASA relation
`clamp_zero_one(lit_frac_lignin * 0.65 * 2.22 / (1 - lit_frac_metabolic))`
evaluated over the per-PFT litter chemistry of `vegQualityTraits_CASA`, so this
approach starts from the values that approach's lignin term produces while
leaving them free to be calibrated on their own. The woody defaults are the
single CASA value, 0.4, which that approach does not resolve per PFT. PFT class 8
has no lignin in that chemistry and therefore gets zero in both.

*References*
 - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.

*Versions*
 - 1.0 on 04.09.2026 [skoirala]: as cQualityPartitionLignin_PFT
 - 2.0 on 10.09.2026 [skoirala]: renamed/relocated into cQualityPartitioncLit, kept as legacy

*Created by*
 - skoirala

"""
cQualityPartitioncLit_PFT
