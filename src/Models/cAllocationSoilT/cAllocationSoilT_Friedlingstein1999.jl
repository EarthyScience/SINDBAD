export cAllocationSoilT_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationSoilT_Friedlingstein1999{T1,T2} <: cAllocationSoilT
    minL_fT::T1 = 0.5 | (0.0, 1.0) | "minimum allocation coefficient from temperature stress" | ""
    maxL_fT::T2 = 1.0 | (0.0, 1.0) | "maximum allocation coefficient from temperature stress" | ""
end

function compute(o::cAllocationSoilT_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilT_Friedlingstein1999 o

    ## unpack land variables
    @unpack_land fT ∈ land.cTauSoilT

    fT = clamp(fT, minL_fT, maxL_fT)

    ## pack land variables
    @pack_land fT => land.cAllocationSoilT
    return land
end

@doc """
partial temperature effect on decomposition/mineralization based on Friedlingstein1999

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - land.cTauSoilT.fT: temperature effect on soil decomposition

*Outputs*
 - land.cAllocationSoilT.fT: temperature stressor on carbon allocation

---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocationSoilT_Friedlingstein1999