export soilWBase_smax2fRD4

#! format: off
@bounds @describe @units @timescale @with_kw struct soilWBase_smax2fRD4{T1,T2,T3,T4,T5,T6} <: soilWBase
    smax1::T1 = 1.0 | (0.001, 1.0) | "maximum soil water holding capacity of 1st soil layer, as % of defined soil depth" | "" | ""
    scalar_Fan::T2 = 0.05 | (0.0, 5.0) | "scaling for rooting depth data to obtain smax2" | "fraction" | ""
    scalar_Yang::T3 = 0.05 | (0.0, 5.0) | "scaling for rooting depth data to obtain smax2" | "fraction" | ""
    scalar_Wang::T4 = 0.05 | (0.0, 5.0) | "scaling for root zone storage capacity data to obtain smax2" | "fraction" | ""
    scalar_Tian::T5 = 0.05 | (0.0, 5.0) | "scaling for plant avaiable water capacity data to obtain smax2" | "fraction" | ""
    smax_Tian::T6 = 50.0 | (0.0, 1000.0) | "value for plant avaiable water capacity data where this is NaN" | "mm" | ""
end
#! format: on

function define(params::soilWBase_smax2fRD4, forcing, land, helpers)
    @unpack_soilWBase_smax2fRD4 params

    @unpack_nt begin
        soilW ⇐ land.pools
        n_soilW ⇐ land.constants
    end
    rootwater_capacities = ones(typeof(smax1), 4)
    if soilW isa SVector
        rootwater_capacities = SVector{4}(rootwater_capacities)
    end

    ## precomputations/check
    # get the soil thickness & root distribution information from input
    soil_layer_thickness = helpers.pools.layer_thickness.soilW
    # check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 2 
    if n_soilW != 2
        error("soilWBase_smax2Layer approach needs eactly 2 soil layers in model_structure.json.")
    end

    ## instantiate variables
    w_sat = zero(soilW)
    w_fc = zero(soilW)
    w_wp = zero(soilW)

    ## pack land variables
    @pack_nt begin
        (soil_layer_thickness, w_sat, w_fc, w_wp) ⇒ land.properties
        rootwater_capacities ⇒ land.soilWBase
    end
    return land
end

function compute(params::soilWBase_smax2fRD4, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_soilWBase_smax2fRD4 params
    @unpack_nt (f_AWC, f_RDeff, f_RDmax, f_SWCmax) ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        (soil_layer_thickness, w_sat, w_fc, w_wp) ⇐ land.properties
        rootwater_capacities ⇐ land.soilWBase
    end

    ## calculate variables
    # get the rooting depth data & scale them
    rootwater_capacities = repElem(rootwater_capacities, f_RDmax[1] * scalar_Fan, rootwater_capacities, rootwater_capacities, 1)
    rootwater_capacities = repElem(rootwater_capacities, f_RDeff[1] * scalar_Yang, rootwater_capacities, rootwater_capacities, 2)
    rootwater_capacities = repElem(rootwater_capacities, f_SWCmax[1] * scalar_Wang, rootwater_capacities, rootwater_capacities, 3)
    AWC_tmp = isInvalid(f_AWC) ? smax_Tian : f_AWC
    rootwater_capacities = repElem(rootwater_capacities, AWC_tmp * scalar_Tian, rootwater_capacities, rootwater_capacities, 4)

    # set the properties for each soil layer
    # 1st layer
    @rep_elem smax1 * soil_layer_thickness[1] ⇒ (w_sat, 1, :soilW)
    @rep_elem smax1 * soil_layer_thickness[1] ⇒ (w_fc, 1, :soilW)

    # 2nd layer - fill in by linaer combination of the RD data
    @rep_elem sum(rootwater_capacities) ⇒ (w_sat, 2, :soilW)
    @rep_elem sum(rootwater_capacities) ⇒ (w_fc, 2, :soilW)

    # get the plant available water available (all the water is plant available)
    w_awc = w_sat

    ## pack land variables
    @pack_nt begin
        (w_sat, w_fc, w_wp) ⇒ land.properties
        rootwater_capacities ⇒ land.soilWBase
    end

    return land
end

@doc """
defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is a linear combination of scaled rooting depth data from forcing

# Parameters
$(SindbadParameters)

---

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_smax2fRD4

*Inputs*
 - forcing.AWC: (plant) available water capacity from Tian et al. 2019
 - forcing.RDeff: effective rooting depth from Yang et al. 2016
 - forcing.RDmax: maximum rooting depth from Fan et al. 2017
 - forcing.SWCmax: maximum soil water capacity from Wang-Erlandsson et al. 2016
 - helpers.pools.: soil layers & depths

*Outputs*
 - land.soilWBase.rootwater_capacities: the 4 scaled RD datas
 - land.properties.p_nsoilLayers
 - land.properties.soil_layer_thickness
 - land.properties.w_awc: = land.properties.w_sat
 - land.properties.w_fc : = land.properties.w_sat
 - land.properties.w_sat: w_sat = smax for 2 soil layers
 - land.properties._wp: wilting point set to zero for all layers

# instantiate:
instantiate/instantiate time-invariant variables for soilWBase_smax2fRD4


---

# Extended help

*References*

*Versions*
 - 1.0 on 10.02.2020 [ttraut]

*Created by:*
 - ttraut
"""
soilWBase_smax2fRD4
