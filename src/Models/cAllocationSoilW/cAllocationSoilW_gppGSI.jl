export cAllocationSoilW_gppGSI

#! format: off
@bounds @describe @units @with_kw struct cAllocationSoilW_gppGSI{T1} <: cAllocationSoilW
    τ_soilW::T1 = 0.8 | (0.001, 1.0) | "temporal change rate for the water-limiting function" | ""
end
#! format: on

function define(p_struct::cAllocationSoilW_gppGSI, forcing, land, helpers)
    fW_prev = sum(land.pools.soilW) / land.soilWBase.sum_wSat

    ## pack land variables
    @pack_land fW_prev => land.cAllocationSoilW
    return land
end

function compute(p_struct::cAllocationSoilW_gppGSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilW_gppGSI p_struct

    ## unpack land variables
    @unpack_land begin
        gpp_f_soilW ∈ land.gppSoilW
        fW_prev ∈ land.cAllocationSoilW
    end
    # computation for the moisture effect on decomposition/mineralization
    c_allocation_f_soilW = fW_prev + (gpp_f_soilW - fW_prev) * τ_soilW

    # set the prev
    fW_prev = c_allocation_f_soilW

    ## pack land variables
    @pack_land (c_allocation_f_soilW, fW_prev) => land.cAllocationSoilW
    return land
end

@doc """
moisture effect on allocation from same for GPP based on GSI approach

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - land.cAllocationSoilW.fW_prev: moisture stressor from previous time step
 - land.gppSoilW.gpp_f_soilW: moisture stressors on GPP

*Outputs*
 - land.cAllocationSoilW.c_allocation_f_soilW: moisture effect on allocation

---

# Extended help

*References*
 - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
 - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology & greenness.
 - Jolly, William M., Ramakrishna Nemani, & Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 [2005]: 619-632.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais & sbesnard
"""
cAllocationSoilW_gppGSI
