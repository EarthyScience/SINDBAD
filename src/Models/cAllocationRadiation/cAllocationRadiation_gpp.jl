export cAllocationRadiation_gpp

struct cAllocationRadiation_gpp <: cAllocationRadiation end

function compute(params::cAllocationRadiation_gpp, forcing, land, helpers)

    ## unpack land variables
    @unpack_land gpp_f_cloud ∈ land.gppDiffRadiation

    ## calculate variables
    # computation for the radiation effect on decomposition/mineralization
    c_allocation_f_cloud = gpp_f_cloud

    ## pack land variables
    @pack_land c_allocation_f_cloud => land.cAllocationRadiation
    return land
end

@doc """
radiation effect on decomposition/mineralization = the same for GPP

---

# compute:

*Inputs*
 - land.gppDiffRadiation.gpp_f_cloud: radiation effect for GPP

*Outputs*
 - land.cAllocationRadiation.c_allocation_f_cloud: radiation effect on decomposition/mineralization

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationRadiation_gpp
