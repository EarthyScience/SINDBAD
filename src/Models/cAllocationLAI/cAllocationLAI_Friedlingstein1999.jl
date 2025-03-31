export cAllocationLAI_Friedlingstein1999

#! format: off
@bounds @describe @units @timescale @with_kw struct cAllocationLAI_Friedlingstein1999{T1,T2,T3} <: cAllocationLAI
    kext::T1 = 0.5 | (0.0, 1.0) | "extinction coefficient of LAI effect on allocation" | "" | ""
    min_f_LAI::T2 = 0.1 | (0.0, 1.0) | "minimum LAI effect on allocation" | "" | ""
    max_f_LAI::T3 = 1.0 | (0.0, 1.0) | "maximum LAI effect on allocation" | "" | ""
end
#! format: on

function compute(params::cAllocationLAI_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationLAI_Friedlingstein1999 params

    ## unpack land variables
    @unpack_nt LAI ⇐ land.states

    ## calculate variables
    # light limitation [c_allocation_f_LAI] calculation
    c_allocation_f_LAI = clamp(exp(-kext * LAI), min_f_LAI, max_f_LAI)

    ## pack land variables
    @pack_nt c_allocation_f_LAI ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocationLAI_Friedlingstein1999}) = "Estimate the effect of light limitation on carbon allocation via leaf area index (LAI) based on Friedlingstein et al., 1999."

@doc """

$(getBaseDocString(cAllocationLAI_Friedlingstein1999))

---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by*
 - ncarvalhais
"""
cAllocationLAI_Friedlingstein1999
