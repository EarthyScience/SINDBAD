export cAllocationSoilT_gpp

struct cAllocationSoilT_gpp <: cAllocationSoilT end

function compute(params::cAllocationSoilT_gpp, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt gpp_f_airT ⇐ land.diagnostics

    ## calculate variables
    # computation for the temperature effect on decomposition/mineralization
    c_allocation_f_soilT = gpp_f_airT

    ## pack land variables
    @pack_nt c_allocation_f_soilT ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocationSoilT_gpp}) = "temperature effect on allocation = the same as gpp"

@doc """

$(getBaseDocString(cAllocationSoilT_gpp))

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala | @dr-ko]  

*Created by*
 - skoirala | @dr-ko
"""
cAllocationSoilT_gpp
