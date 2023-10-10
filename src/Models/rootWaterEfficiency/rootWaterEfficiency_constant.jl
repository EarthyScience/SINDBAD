export rootWaterEfficiency_constant

#! format: off
@bounds @describe @units @with_kw struct rootWaterEfficiency_constant{T1} <: rootWaterEfficiency
    constant_root_water_efficiency::T1 = 0.05 | (0.01, 0.15) | "root fraction" | ""
end
#! format: on

function define(p_struct::rootWaterEfficiency_constant, forcing, land, helpers)
    @unpack_rootWaterEfficiency_constant p_struct
    
    @unpack_land begin
        soil_layer_thickness ∈ land.soilWBase
        soilW ∈ land.pools            
    end

    cumulative_soil_depths = cumsum(soil_layer_thickness)
    ## instantiate
    root_water_efficiency = one.(soilW)

    ## pack land variables
    @pack_land begin
        root_water_efficiency => land.states
        cumulative_soil_depths => land.rootWaterEfficiency
    end

    return land
end


function precompute(p_struct::rootWaterEfficiency_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootWaterEfficiency_constant p_struct
    ## unpack land variables
    @unpack_land begin
        cumulative_soil_depths ∈ land.rootWaterEfficiency
        root_water_efficiency ∈ land.states
        soilW ∈ land.pools
        z_zero ∈ land.wCycleBase
        max_root_depth ∈ land.states
    end
    if max_root_depth >= z_zero
        @rep_elem constant_root_water_efficiency => (root_water_efficiency, 1, :soilW)
    end
    for sl ∈ eachindex(soilW)[2:end]
        soilcumuD = cumulative_soil_depths[sl-1]
        rootOver = max_root_depth - soilcumuD
        rootEff = rootOver >= z_zero ? constant_root_water_efficiency : zero(eltype(root_water_efficiency))
        @rep_elem rootEff => (root_water_efficiency, sl, :soilW)
    end
    ## pack land variables
    @pack_land root_water_efficiency => land.states
    return land
end


@doc """
sets the maximum fraction of water that root can uptake from soil layers as constant

# Parameters
$(SindbadParameters)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootWaterEfficiency_constant

*Inputs*
 - land.states.maxRootD

*Outputs*
 - land.states.root_water_efficiency

# instantiate:
instantiate/instantiate time-invariant variables for rootWaterEfficiency_constant


---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
rootWaterEfficiency_constant
