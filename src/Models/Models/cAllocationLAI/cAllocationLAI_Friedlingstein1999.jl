export cAllocationLAI_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationLAI_Friedlingstein1999{T1,T2,T3} <: cAllocationLAI
    kext::T1 = 0.5 | (0.0, 1.0) | "extinction coefficient of LAI effect on allocation" | ""
    minL::T2 = 0.1 | (0.0, 1.0) | "minimum LAI effect on allocation" | ""
    maxL::T3 = 1.0 | (0.0, 1.0) | "maximum LAI effect on allocation" | ""
end

function compute(o::cAllocationLAI_Friedlingstein1999, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters
    @unpack_cAllocationLAI_Friedlingstein1999 o

    ## unpack land variables
    @unpack_land LAI ∈ land.states

    ## calculate variables
    # light limitation [LL] calculation
    LL = clamp(exp(-kext * LAI), minL, maxL)

    ## pack land variables
    @pack_land LL => land.cAllocationLAI
    return land
end

@doc """
LAI effect on allocation based on light limitation from Friedlingstein1999

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of lai on carbon allocation using cAllocationLAI_Friedlingstein1999

*Inputs*
 - land.states.LAI: values for leaf area index

*Outputs*
 - land.cAllocationLAI.LL: values for light limitation
 - land.cAllocationLAI.LL

---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocationLAI_Friedlingstein1999