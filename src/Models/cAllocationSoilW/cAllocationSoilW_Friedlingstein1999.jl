export cAllocationSoilW_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationSoilW_Friedlingstein1999{T1,T2} <: cAllocationSoilW
    minL_fW::T1 = 0.5 | (0.0, 1.0) | "minimum value for moisture stressor" | ""
    maxL_fW::T2 = 0.8 | (0.0, 1.0) | "maximum value for moisture stressor" | ""
end

function compute(o::cAllocationSoilW_Friedlingstein1999, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters
    @unpack_cAllocationSoilW_Friedlingstein1999 o

    ## unpack land variables
    @unpack_land fW_cTau = fW ∈ land.cTauSoilW

    ## calculate variables
    # computation for the moisture effect on decomposition/mineralization
    fW = clamp(fW_cTau, minL_fW, maxL_fW)

    ## pack land variables
    @pack_land fW => land.cAllocationSoilW
    return land
end

@doc """
partial moisture effect on decomposition/mineralization based on Friedlingstein1999

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - land.cTauSoilW.fW: moisture effect on soil decomposition rate

*Outputs*
 - land.cAllocationSoilW.fW: moisture stressor on C allocation

---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocationSoilW_Friedlingstein1999