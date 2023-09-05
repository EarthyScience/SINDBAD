export soilWBase_smax2Layer

#! format: off
@bounds @describe @units @with_kw struct soilWBase_smax2Layer{T1,T2} <: soilWBase
    smax1::T1 = 1.0 | (0.001, 1.0) | "maximum soil water holding capacity of 1st soil layer, as % of defined soil depth" | ""
    smax2::T2 = 0.3 | (0.01, 1.0) | "maximum plant available water in 2nd soil layer, as % of defined soil depth" | ""
end
#! format: on

function define(p_struct::soilWBase_smax2Layer, forcing, land, helpers)
    @unpack_soilWBase_smax2Layer p_struct

    @unpack_land begin
        soilW ∈ land.pools
        n_soilW ∈ land.wCycleBase
    end
    ## precomputations/check
    # get the soil thickness & root distribution information from input
    soil_layer_thickness = helpers.pools.layer_thickness.soilW
    # check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 2 
    if n_soilW != 2
        error("soilWBase_smax2Layer needs eactly 2 soil layers in model_structure.json.")
    end

    ## instantiate variables
    wSat = zero(land.pools.soilW)
    wFC = zero(land.pools.soilW)
    wWP = zero(land.pools.soilW)

    ## pack land variables
    @pack_land (soil_layer_thickness, wSat, wFC, wWP) => land.soilWBase
    return land
end

function compute(p_struct::soilWBase_smax2Layer, forcing, land, helpers)
    ## unpack parameters
    @unpack_soilWBase_smax2Layer p_struct

    ## unpack land variables
    @unpack_land (soil_layer_thickness, wSat, wFC, wWP) ∈ land.soilWBase

    ## calculate variables
    # set the properties for each soil layer
    # 1st layer
    @rep_elem smax1 * soil_layer_thickness[1] => (wSat, 1, :soilW)
    @rep_elem smax2 * soil_layer_thickness[2] => (wSat, 2, :soilW)
    @rep_elem smax1 * soil_layer_thickness[1] => (wFC, 1, :soilW)
    @rep_elem smax2 * soil_layer_thickness[2] => (wFC, 2, :soilW)

    # get the plant available water available (all the water is plant available)
    wAWC = wSat

    ## pack land variables
    @pack_land (wAWC, wFC, wSat, wWP, n_soilW, soil_layer_thickness) => land.soilWBase
    return land
end

@doc """
defines the maximum soil water content of 2 soil layers as fraction of the soil depth defined in the model_structure.json based on the older version of the Pre-Tokyo Model

# Parameters
$(SindbadParameters)

---

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_smax2Layer

*Inputs*
 - helpers.pools.: soil layers & depths

*Outputs*
 - land.soilWBase.p_nsoilLayers
 - land.soilWBase.soil_layer_thickness
 - land.soilWBase.wAWC: = land.soilWBase.wSat
 - land.soilWBase.wFC : = land.soilWBase.wSat
 - land.soilWBase.wSat: wSat = smax for 2 soil layers
 - land.soilWBase.WP: wilting point set to zero for all layers

# instantiate:
instantiate/instantiate time-invariant variables for soilWBase_smax2Layer


---

# Extended help

*References*

*Versions*
 - 1.0 on 09.01.2020 [ttraut]: clean up & consistency  

*Created by:*
 - ttraut
"""
soilWBase_smax2Layer
