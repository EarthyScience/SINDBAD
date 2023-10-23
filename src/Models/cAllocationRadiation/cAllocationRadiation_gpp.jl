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

@doc """
radiation effect on decomposition/mineralization = the same for GPP

---

# compute:

*Inputs*
 - land.diagnostics.gpp_f_cloud: radiation effect for GPP

*Outputs*
 - land.diagnostics.c_allocation_f_cloud: radiation effect on decomposition/mineralization

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationRadiation_gpp
