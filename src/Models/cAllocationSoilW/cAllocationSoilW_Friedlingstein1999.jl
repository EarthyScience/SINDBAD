export cAllocationSoilW_Friedlingstein1999

#! format: off
@bounds @describe @units @with_kw struct cAllocationSoilW_Friedlingstein1999{T1,T2} <: cAllocationSoilW
    min_f_soilW::T1 = 0.5 | (0.0, 1.0) | "minimum value for moisture stressor" | ""
    max_f_soilW::T2 = 0.8 | (0.0, 1.0) | "maximum value for moisture stressor" | ""
end
#! format: on

function compute(params::cAllocationSoilW_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilW_Friedlingstein1999 params

    ## unpack land variables
    @unpack_land c_eco_k_f_soilW ∈ land.cTauSoilW

    ## calculate variables
    # computation for the moisture effect on decomposition/mineralization
    c_allocation_f_soilW = clamp(mean(c_eco_k_f_soilW), min_f_soilW, max_f_soilW)

    ## pack land variables
    @pack_land c_allocation_f_soilW => land.cAllocationSoilW
    return land
end

@doc """
partial moisture effect on decomposition/mineralization based on Friedlingstein1999

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - land.cTauSoilW.c_allocation_f_soilW: moisture effect on soil decomposition rate

*Outputs*
 - land.cAllocationSoilW.c_allocation_f_soilW: moisture stressor on C allocation

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
