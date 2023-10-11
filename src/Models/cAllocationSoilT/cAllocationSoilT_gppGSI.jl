export cAllocationSoilT_gppGSI

#! format: off
@bounds @describe @units @with_kw struct cAllocationSoilT_gppGSI{T1} <: cAllocationSoilT
    τ_Tsoil::T1 = 0.2 | (0.001, 1.0) | "temporal change rate for the temperature-limiting function" | ""
end
#! format: on

function define(params::cAllocationSoilT_gppGSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilT_gppGSI params

    # assume initial prev as one (no stress)
    f_soilT_prev = land.wCycleBase.o_one

    @pack_land f_soilT_prev => land.cAllocationSoilT
    return land
end

function compute(params::cAllocationSoilT_gppGSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilT_gppGSI params

    ## unpack land variables
    @unpack_land begin
        gpp_f_airT ∈ land.gppAirT
        f_soilT_prev ∈ land.cAllocationSoilT
    end

    # computation for the temperature effect on decomposition/mineralization
    c_allocation_f_soilT = f_soilT_prev + (gpp_f_airT - f_soilT_prev) * τ_Tsoil

    # set the prev
    f_soilT_prev = c_allocation_f_soilT

    ## pack land variables
    @pack_land (c_allocation_f_soilT, f_soilT_prev) => land.cAllocationSoilT
    return land
end

@doc """
temperature effect on allocation from same for GPP based on GSI approach

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - land.cAllocationSoilT.f_soilT_prev: temperature stressor from previous time step
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
