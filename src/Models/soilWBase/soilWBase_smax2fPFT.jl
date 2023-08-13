export soilWBase_smax2fPFT

#! format: off
@bounds @describe @units @with_kw struct soilWBase_smax2fPFT{T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13} <: soilWBase
    smax1::T1 = 1.0 | (0.001, 1.0) | "maximum soil water holding capacity of 1st soil layer, as % of defined soil depth" | ""
    smaxPFT0::T2 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 0, as % of defined soil depth" | "fraction"
    smaxPFT1::T3 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 1, as % of defined soil depth" | "fraction"
    smaxPFT2::T4 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 2, as % of defined soil depth" | "fraction"
    smaxPFT3::T5 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 3, as % of defined soil depth" | "fraction"
    smaxPFT4::T6 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 4, as % of defined soil depth" | "fraction"
    smaxPFT5::T7 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 5, as % of defined soil depth" | "fraction"
    smaxPFT6::T8 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 6, as % of defined soil depth" | "fraction"
    smaxPFT7::T9 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 7, as % of defined soil depth" | "fraction"
    smaxPFT8::T10 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 8, as % of defined soil depth" | "fraction"
    smaxPFT9::T11 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 9, as % of defined soil depth" | "fraction"
    smaxPFT10::T12 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 10, as % of defined soil depth" | "fraction"
    smaxPFT11::T13 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 11, as % of defined soil depth" | "fraction"
end
#! format: on

function define(p_struct::soilWBase_smax2fPFT, forcing, land, helpers)
    #@needscheck
    @unpack_soilWBase_smax2fPFT p_struct

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

function compute(p_struct::soilWBase_smax2fPFT, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_soilWBase_smax2fPFT p_struct

    ## unpack land variables
    @unpack_land (soil_layer_thickness, wSat, wFC, wWP) ∈ land.soilWBase
    @unpack_forcing PFT ∈ forcing

    ## calculate variables
    # get the PFT data & assign parameters
    tmp_classes = unique(PFT)
    p_smaxPFT = 1.0
    for nC ∈ eachindex(tmp_classes)
        nPFT = tmp_classes[nC]
        p_tmp = eval(char(["smaxPFT" num2str(nPFT)]))
        p_smaxPFT[PFT==nPFT, 1] = soil_layer_thickness[2] * p_tmp #
    end
    # set the properties for each soil layer
    # 1st layer
    wSat[1] = smax1 * soilDepths[1]
    wFC[1] = smax1 * soilDepths[1]
    # 2nd layer - fill in by linaer combination of the RD data
    wSat[2] = p_smaxPFT
    wFC[2] = p_smaxPFT
    # get the plant available water available
    # (all the water is plant available)
    wAWC = wSat

    ## pack land variables
    @pack_land (p_nsoilLayers,
        p_smaxPFT,
        soil_layer_thickness,
        wAWC,
        wFC,
        wSat,
        wWP,
        n_soilW) => land.soilWBase
    return land
end

@doc """
defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is defined as PFT specific parameters from forcing

# Parameters
$(SindbadParameters)

---

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_smax2fPFT

*Inputs*
 - forcing.PFT: PFT classes
 - helpers.pools.: soil layers & depths

*Outputs*
 - land.soilWBase.p_nsoilLayers
 - land.soilWBase.p_smaxPFT: the combined parameters [pix, 1]
 - land.soilWBase.soil_layer_thickness
 - land.soilWBase.wAWC: = land.soilWBase.wSat
 - land.soilWBase.wFC : = land.soilWBase.wSat
 - land.soilWBase.wSat: wSat = smax for 2 soil layers
 - land.soilWBase.WP: wilting point set to zero for all layers

# instantiate:
instantiate/instantiate time-invariant variables for soilWBase_smax2fPFT


---

# Extended help

*References*

*Versions*
 - 1.0 on 10.09.2021 [ttraut]

*Created by:*
 - ttraut
"""
soilWBase_smax2fPFT
