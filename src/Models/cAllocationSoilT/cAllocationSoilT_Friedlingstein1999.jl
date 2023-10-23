export cAllocationSoilT_Friedlingstein1999

#! format: off
@bounds @describe @units @with_kw struct cAllocationSoilT_Friedlingstein1999{T1,T2} <: cAllocationSoilT
    min_f_soilT::T1 = 0.5 | (0.0, 1.0) | "minimum allocation coefficient from temperature stress" | ""
    max_f_soilT::T2 = 1.0 | (0.0, 1.0) | "maximum allocation coefficient from temperature stress" | ""
end
#! format: on

function compute(params::cAllocationSoilT_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilT_Friedlingstein1999 params

    ## unpack land variables
    @unpack_nt c_allocation_f_soilT ⇐ land.diagnostics

    c_allocation_f_soilT = clamp(c_allocation_f_soilT, min_f_soilT, max_f_soilT)

    ## pack land variables
    @pack_nt c_allocation_f_soilT ⇒ land.diagnostics
    return land
end

@doc """
partial temperature effect on decomposition/mineralization based on Friedlingstein1999

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - land.diagnostics.c_allocation_f_soilT: temperature effect on soil decomposition

*Outputs*
 - land.diagnostics.c_allocation_f_soilT: temperature stressor on carbon allocation

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
