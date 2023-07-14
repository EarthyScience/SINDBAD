export cAllocationSoilT_gppGSI

#! format: off
@bounds @describe @units @with_kw struct cAllocationSoilT_gppGSI{T1} <: cAllocationSoilT
    τ_Tsoil::T1 = 0.2 | (0.001, 1.0) | "temporal change rate for the temperature-limiting function" | ""
end
#! format: on

function define(p_struct::cAllocationSoilT_gppGSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilT_gppGSI p_struct

    ## unpack land variables
    @unpack_land begin
        𝟙 ∈ helpers.numbers
    end
    # assume initial prev as one (no stress)
    fT_prev = 𝟙

    @pack_land fT_prev => land.cAllocationSoilT
    return land
end

function compute(p_struct::cAllocationSoilT_gppGSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilT_gppGSI p_struct

    ## unpack land variables
    @unpack_land begin
        gpp_f_airT ∈ land.gppAirT
        fT_prev ∈ land.cAllocationSoilT
    end

    # computation for the temperature effect on decomposition/mineralization
    c_allocation_f_soilT = fT_prev + (gpp_f_airT - fT_prev) * τ_Tsoil

    # set the prev
    fT_prev = c_allocation_f_soilT

    ## pack land variables
    @pack_land (c_allocation_f_soilT, fT_prev) => land.cAllocationSoilT
    return land
end

@doc """
temperature effect on allocation from same for GPP based on GSI approach

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - land.cAllocationSoilT.fT_prev: temperature stressor from previous time step
 - land.gppAirT.gpp_f_airT: temperature stressors on GPP

*Outputs*
 - land.cAllocationSoilT.c_allocation_f_soilT: temperature effect on decomposition/mineralization (0-1)

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
cAllocationSoilT_gppGSI
