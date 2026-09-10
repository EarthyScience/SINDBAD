export cQualityPartitioncLit_vegQualityTraits

struct cQualityPartitioncLit_vegQualityTraits <: cQualityPartitioncLit end

function define(params::cQualityPartitioncLit_vegQualityTraits, forcing, land, helpers)
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

function precompute(params::cQualityPartitioncLit_vegQualityTraits, forcing, land, helpers)
    ## unpack land variables
    @unpack_nt begin
        c_flow_QP_f_cLit ⇐ land.diagnostics
        c_flow_named_edges ⇐ land.cCycleBase
        (lit_frac_lignin_struct, lit_frac_lignin_wood) ⇐ land.properties
        o_one ⇐ land.constants
    end

    ## calculate variables
    for (stabilized_edge, microbial_edge) ∈ QP_CLIT_STRUCT_GROUPS
        c_flow_QP_f_cLit = setQPGroup(c_flow_QP_f_cLit, c_flow_named_edges,
            (stabilized_edge, microbial_edge),
            (lit_frac_lignin_struct, o_one - lit_frac_lignin_struct))
    end
    for (stabilized_edge, microbial_edge) ∈ QP_CLIT_WOOD_GROUPS
        c_flow_QP_f_cLit = setQPGroup(c_flow_QP_f_cLit, c_flow_named_edges,
            (stabilized_edge, microbial_edge),
            (lit_frac_lignin_wood, o_one - lit_frac_lignin_wood))
    end

    ## pack land variables
    @pack_nt c_flow_QP_f_cLit ⇒ land.diagnostics
    return land
end

purpose(::Type{cQualityPartitioncLit_vegQualityTraits}) = "Lignin control of the carbon-quality partition, read directly from vegQualityTraits so the partition always matches the litter chemistry actually in use."

@doc """

	$(getModelDocString(cQualityPartitioncLit_vegQualityTraits))

---

# Extended help

Reads `lit_frac_lignin_struct` and `lit_frac_lignin_wood` from `land.properties`,
published by whichever `vegQualityTraits` approach is selected, and writes each,
with its complement, into the flows of `QP_CLIT_STRUCT_GROUPS` and
`QP_CLIT_WOOD_GROUPS`. No parameters of its own: the litter chemistry is declared
exactly once, in `vegQualityTraits`.

This is the properly-connected replacement for the legacy
[`cQualityPartitioncLit_PFT`](@ref), whose per-PFT table never read
`vegQualityTraits`' actual output and could silently disagree with it.

*References*

*Versions*
 - 1.0 on 10.09.2026 [skoirala]

*Created by*
 - skoirala

"""
cQualityPartitioncLit_vegQualityTraits
