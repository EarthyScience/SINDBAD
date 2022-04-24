export cAllocationNutrients_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationNutrients_Friedlingstein1999{T1,T2} <: cAllocationNutrients
    minL::T1 = 0.1 | (0.0, 1.0) | "" | ""
    maxL::T2 = 1.0 | (0.0, 1.0) | "" | ""
end


function compute(o::cAllocationNutrients_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationNutrients_Friedlingstein1999 o

    ## unpack land variables
    @unpack_land begin
        PAW ∈ land.vegAvailableWater
        s_wAWC ∈ land.soilWBase
        fW ∈ land.cAllocationSoilW
        fT ∈ land.cAllocationSoilT
        PET ∈ land.PET
        one ∈ helpers.numbers
    end

    # estimate NL
    nl = clamp(fT * fW, minL, maxL)
    NL = PET > zero ? nl : one #@needscheck is the else value one or zero? In matlab version was set to ones.

    # water limitation calculation
    WL = clamp(sum(PAW) / s_wAWC, minL, maxL)

    # minimum of WL & NL
    minWLNL = min(WL, NL)

    ## pack land variables
    @pack_land minWLNL => land.cAllocationNutrients
    return land
end

@doc """
pseudo-nutrient limitation calculation based on Friedlingstein1999

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - land.PET.PET: values for potential evapotranspiration
 - land.cAllocationSoilT.fT: values for partial computation for the temperature effect on  decomposition/mineralization
 - land.cAllocationSoilW.fW: values for partial computation for the moisture effect on  decomposition/mineralization
 - land.soilWBase.s_wAWC: sum of water available capacity
 - land.vegAvailableWater.PAW: values for maximum fraction of water that root can uptake from soil layers as constant

*Outputs*
 - land.cAllocationNutrients.minWLNL: nutrient limitation on cAllocation

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