export cAllocationRadiation_gpp

struct cAllocationRadiation_gpp <: cAllocationRadiation end

function compute(params::cAllocationRadiation_gpp, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt gpp_f_cloud ⇐ land.diagnostics

    ## calculate variables
    # computation for the radiation effect on decomposition/mineralization
    c_allocation_f_cloud = gpp_f_cloud

    ## pack land variables
    @pack_nt c_allocation_f_cloud ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocationRadiation_gpp}) = "Sets the radiation effect on allocation equal to that for GPP."

@doc """

$(getModelDocString(cAllocationRadiation_gpp))

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala | @dr-ko]  

*Created by*
 - skoirala | @dr-ko
"""
cAllocationRadiation_gpp
