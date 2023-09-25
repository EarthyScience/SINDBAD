export cAllocationRadiation_GSI

#! format: off
@bounds @describe @units @with_kw struct cAllocationRadiation_GSI{T1,T2,T3} <: cAllocationRadiation
    τ_Rad::T1 = 0.02 | (0.001, 1.0) | "temporal change rate for the light-limiting function" | ""
    slope_Rad::T2 = 1.0 | (0.01, 200.0) | "slope parameters of a logistic function based on mean daily y shortwave downward radiation" | ""
    base_Rad::T3 = 10.0 | (0.0, 100.0) | "inflection point parameters of a logistic function based on mean daily y shortwave downward radiation" | ""
end
#! format: on

function define(p_struct::cAllocationRadiation_GSI, forcing, land, helpers)
    ## unpack helper

    ## calculate variables
    # assume the initial c_allocation_f_cloud as one
    fR_prev = one(slope_Rad)

    ## pack land variables
    @pack_land fR_prev => land.cAllocationRadiation
    return land
end

function compute(p_struct::cAllocationRadiation_GSI, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_cAllocationRadiation_GSI p_struct
    @unpack_forcing PAR ∈ forcing

    ## unpack land variables
    @unpack_land begin
        fR_prev ∈ land.cAllocationRadiation
        (z_zero, o_one) ∈ land.wCycleBase
    end
    ## calculate variables
    # computation for the radiation effect on decomposition/mineralization
    c_allocation_f_cloud = (one(slope_Rad) / (one(slope_Rad) + exp(-slope_Rad * (PAR - base_Rad))))
    c_allocation_f_cloud = fR_prev + (c_allocation_f_cloud - fR_prev) * τ_Rad
    # set the prev
    fR_prev = c_allocation_f_cloud

    ## pack land variables
    @pack_land (c_allocation_f_cloud, fR_prev) => land.cAllocationRadiation
    return land
end

@doc """
radiation effect on decomposition/mineralization using GSI method

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - forcing.PAR: Photosynthetically Active Radiation
 - land.cAllocationRadiation.fR_prev: radiation effect on decomposition/mineralization from the previous time step

*Outputs*
 - land.cAllocationRadiation.c_allocation_f_cloud: radiation effect on decomposition/mineralization

---

# Extended help

*References*
 - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
 - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology & greenness.
 - Jolly, William M., Ramakrishna Nemani, & Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 [2005]: 619-632.

*Versions*
 - 1.0 on 12.01.2020 [skoirala]  

*Created by:*
 - ncarvalhais, sbesnard, skoirala
"""
cAllocationRadiation_GSI
