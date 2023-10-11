export cAllocationSoilT_gpp

struct cAllocationSoilT_gpp <: cAllocationSoilT end

function compute(params::cAllocationSoilT_gpp, forcing, land, helpers)

    ## unpack land variables
    @unpack_land gpp_f_airT ∈ land.gppAirT

    ## calculate variables
    # computation for the temperature effect on decomposition/mineralization
    c_allocation_f_soilT = gpp_f_airT

    ## pack land variables
    @pack_land c_allocation_f_soilT => land.cAllocationSoilT
    return land
end

@doc """
temperature effect on allocation = the same as gpp

---

# compute:

*Inputs*
 - land.gppAirT.gpp_f_airT: temperature stressors on GPP

*Outputs*
 - land.cAllocationSoilT.c_allocation_f_soilT: temperature effect on decomposition/mineralization

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationSoilT_gpp
