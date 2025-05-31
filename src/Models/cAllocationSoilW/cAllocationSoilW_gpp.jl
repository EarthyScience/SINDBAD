export cAllocationSoilW_gpp

struct cAllocationSoilW_gpp <: cAllocationSoilW end

function compute(params::cAllocationSoilW_gpp, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt gpp_f_soilW ⇐ land.diagnostics

    ## calculate variables
    # computation for the moisture effect on decomposition/mineralization
    c_allocation_f_soilW = gpp_f_soilW

    ## pack land variables
    @pack_nt c_allocation_f_soilW ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocationSoilW_gpp}) = "Sets the moisture effect on allocation equal to that for GPP."

@doc """

$(getModelDocString(cAllocationSoilW_gpp))

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala | @dr-ko]  

*Created by*
 - skoirala | @dr-ko
"""
cAllocationSoilW_gpp
