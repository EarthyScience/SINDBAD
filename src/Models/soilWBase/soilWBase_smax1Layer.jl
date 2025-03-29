export soilWBase_smax1Layer

#! format: off
@bounds @describe @units @timescale @with_kw struct soilWBase_smax1Layer{T1} <: soilWBase
    smax::T1 = 1.0 | (0.001, 10.0) | "maximum soil water holding capacity of 1st soil layer, as % of defined soil depth" | "" | ""
end
#! format: on

function define(params::soilWBase_smax1Layer, forcing, land, helpers)
    @unpack_soilWBase_smax1Layer params

    @unpack_nt begin
        soilW ⇐ land.pools
        n_soilW ⇐ land.constants
    end
    ## precomputations/check
    # get the soil thickness & root distribution information from input
    soil_layer_thickness = helpers.pools.layer_thickness.soilW
    # check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 1 
    if n_soilW != 1
        error(["soilWBase_smax1Layer needs eactly 1 soil layer in model_structure.json."])
    end

    ## Instantiate variables
    w_sat = zero(soilW)
    w_fc = zero(soilW)
    w_wp = zero(soilW)

    ## pack land variables
    @pack_nt (soil_layer_thickness, w_sat, w_fc, w_wp) ⇒ land.properties
    return land
end

function compute(params::soilWBase_smax1Layer, forcing, land, helpers)
    ## unpack parameters
    @unpack_soilWBase_smax1Layer params

    ## unpack land variables
    @unpack_nt (soil_layer_thickness, w_sat, w_fc, w_wp) ⇐ land.properties

    ## calculate variables

    # set the properties for each soil layer
    # 1st layer
    w_sat[1] = smax * soil_layer_thickness[1]
    w_fc[1] = smax * soil_layer_thickness[1]

    # get the plant available water available (all the water is plant available)
    w_awc = w_sat

    ## pack land variables
    @pack_nt (w_awc, w_fc, w_sat, w_wp) ⇒ land.properties
    return land
end

purpose(::Type{soilWBase_smax1Layer}) = "defines the maximum soil water content of 1 soil layer as fraction of the soil depth defined in the model_structure.json based on the TWS model for the Northern Hemisphere"

@doc """

$(getBaseDocString())

---

# Extended help

*References*
 - Trautmann et al. 2018

*Versions*
 - 1.0 on 09.01.2020 [ttraut]: clean up & consistency  

*Created by:*
 - ttraut
"""
soilWBase_smax1Layer
