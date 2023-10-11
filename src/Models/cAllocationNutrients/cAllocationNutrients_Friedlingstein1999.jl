export cAllocationNutrients_Friedlingstein1999

#! format: off
@bounds @describe @units @with_kw struct cAllocationNutrients_Friedlingstein1999{T1,T2} <: cAllocationNutrients
    min_L::T1 = 0.1 | (0.0, 1.0) | "" | ""
    max_L::T2 = 1.0 | (0.0, 1.0) | "" | ""
end
#! format: on

function compute(params::cAllocationNutrients_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationNutrients_Friedlingstein1999 params

    ## unpack land variables
    @unpack_land begin
        PAW ∈ land.states
        sum_wAWC ∈ land.soilWBase
        c_allocation_f_soilW ∈ land.cAllocationSoilW
        c_allocation_f_soilT ∈ land.cAllocationSoilT
        PET ∈ land.fluxes
        (z_zero, o_one) ∈ land.wCycleBase
    end

    # estimate NL
    nl = clamp(c_allocation_f_soilT * c_allocation_f_soilW, min_L, max_L)
    NL = PET > z_zero ? nl : one(nl) #@needscheck is the else value one or zero? In matlab version was set to ones.

    # water limitation calculation
    WL = clamp(sum(PAW) / sum_wAWC, min_L, max_L)

    # minimum of WL & NL
    c_allocation_f_W_N = min(WL, NL)

    ## pack land variables
    @pack_land c_allocation_f_W_N => land.cAllocationNutrients
    return land
end

@doc """
pseudo-nutrient limitation calculation based on Friedlingstein1999

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - land.fluxes.PET: values for potential evapotranspiration
 - land.cAllocationSoilT.c_allocation_f_soilT: values for partial computation for the temperature effect on  decomposition/mineralization
 - land.cAllocationSoilW.c_allocation_f_soilW: values for partial computation for the moisture effect on  decomposition/mineralization
 - land.soilWBase.sum_wAWC: sum of water available capacity
 - land.states.PAW: values for maximum fraction of water that root can uptake from soil layers as constant

*Outputs*
 - land.cAllocationNutrients.c_allocation_f_W_N: nutrient limitation on cAllocation

---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Notes*
 -  "There is no explicit estimate of soil mineral nitrogen in the version of CASA used for these simulations. As a surrogate; we assume that spatial variability in nitrogen mineralization & soil organic matter decomposition are identical [Townsend et al. 1995]. Nitrogen availability; N; is calculated as the product of the temperature & moisture abiotic factors used in CASA for the calculation of microbial respiration [Potter et al. 1993]." in Friedlingstein et al., 1999.#

 *Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocationNutrients_Friedlingstein1999
