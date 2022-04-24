export cAllocationSoilW_gpp

struct cAllocationSoilW_gpp <: cAllocationSoilW end

function compute(o::cAllocationSoilW_gpp, forcing, land, helpers)

    ## unpack land variables
    @unpack_land SMScGPP ∈ land.gppSoilW


    ## calculate variables
    # computation for the moisture effect on decomposition/mineralization
    fW = SMScGPP

    ## pack land variables
    @pack_land fW => land.cAllocationSoilW
    return land
end

@doc """
moisture effect on allocation = the same as gpp

---

# compute:

*Inputs*
 - land.gppSoilW.SMScGPP: moisture stressor on GPP

*Outputs*
 - land.cAllocationSoilW.fW: moisture effect on allocation

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationSoilW_gpp