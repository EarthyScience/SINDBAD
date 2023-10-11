export cAllocationRadiation_GSI

#! format: off
@bounds @describe @units @with_kw struct cAllocationRadiation_GSI{T1,T2,T3} <: cAllocationRadiation
    τ_rad::T1 = 0.02 | (0.001, 1.0) | "temporal change rate for the light-limiting function" | ""
    slope_rad::T2 = 1.0 | (0.01, 200.0) | "slope parameters of a logistic function based on mean daily y shortwave downward radiation" | ""
    base_rad::T3 = 10.0 | (0.0, 100.0) | "inflection point parameters of a logistic function based on mean daily y shortwave downward radiation" | ""
end
#! format: on

function define(params::cAllocationRadiation_GSI, forcing, land, helpers)
    ## unpack helper

    ## calculate variables
    # assume the initial c_allocation_f_cloud as one
    f_cloud_prev = one(slope_rad)

    ## pack land variables
    @pack_land f_cloud_prev => land.cAllocationRadiation
    return land
end

function compute(params::cAllocationRadiation_GSI, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_cAllocationRadiation_GSI params
    @unpack_forcing f_PAR ∈ forcing

    ## unpack land variables
    @unpack_land begin
        f_cloud_prev ∈ land.cAllocationRadiation
        (z_zero, o_one) ∈ land.wCycleBase
    end
    ## calculate variables
    # computation for the radiation effect on decomposition/mineralization
    c_allocation_f_cloud = (one(slope_rad) / (one(slope_rad) + exp(-slope_rad * (f_PAR - base_rad))))
    c_allocation_f_cloud = f_cloud_prev + (c_allocation_f_cloud - f_cloud_prev) * τ_rad
    # set the prev
    f_cloud_prev = c_allocation_f_cloud

    ## pack land variables
    @pack_land (c_allocation_f_cloud, f_cloud_prev) => land.cAllocationRadiation
    return land
end

@doc """
radiation effect on decomposition/mineralization using GSI method

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - forcing.f_PAR: Photosynthetically Active Radiation
 - land.cAllocationRadiation.f_cloud_prev: radiation effect on decomposition/mineralization from the previous time step

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
