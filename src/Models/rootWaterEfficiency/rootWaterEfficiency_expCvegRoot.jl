export rootWaterEfficiency_expCvegRoot

#! format: off
@bounds @describe @units @with_kw struct rootWaterEfficiency_expCvegRoot{T1,T2,T3} <: rootWaterEfficiency
    k_efficiency_cVegRoot::T1 = 0.02 | (0.001, 0.3) | "rate constant of exponential relationship" | "m2/kgC (inverse of carbon storage)"
    max_root_water_efficiency::T2 = 0.95 | (0.7, 0.98) | "maximum root water uptake capacity" | ""
    min_root_water_efficiency::T3 = 0.1 | (0.05, 0.3) | "minimum root water uptake threshold" | ""
end
#! format: on

function define(p_struct::rootWaterEfficiency_expCvegRoot, forcing, land, helpers)
    @unpack_rootWaterEfficiency_expCvegRoot p_struct
    @unpack_land begin
        soil_layer_thickness ∈ land.soilWBase
    end
    ## instantiate variables
    root_water_efficiency = one.(land.pools.soilW)
    cumulative_soil_depths = cumsum(soil_layer_thickness)
    root_over = one.(land.pools.soilW)
    ## pack land variables
    @pack_land begin
        (root_over, cumulative_soil_depths) => land.rootWaterEfficiency
        root_water_efficiency => land.states
    end
    return land
end

function precompute(p_struct::rootWaterEfficiency_expCvegRoot, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootWaterEfficiency_expCvegRoot p_struct
    ## unpack land variables
    @unpack_land begin
        (root_over, cumulative_soil_depths) ∈ land.rootWaterEfficiency
        z_zero ∈ land.wCycleBase
        max_root_depth ∈ land.states
    end
    if max_root_depth > z_zero
        @rep_elem one(eltype(root_over)) => (root_over, 1, :soilW)
    end
    root_over = inner_pool(land.pools.soilW, root_over, cumulative_soil_depths, max_root_depth, z_zero, helpers)
    ## pack land variables
    @pack_land root_over => land.rootWaterEfficiency
    return land
end

function inner_pool(land_pools_soilW, root_over, cumulative_soil_depths, max_root_depth, z_zero, helpers)
    for sl ∈ eachindex(land_pools_soilW)[2:end]
        soilcumuD = cumulative_soil_depths[sl-1]
        rootOver = max_root_depth - soilcumuD
        rootEff = rootOver >= z_zero ? one(eltype(root_over)) : zero(eltype(root_over))
        @rep_elem rootEff => (root_over, sl, :soilW)
    end
    return root_over
end

function compute(p_struct::rootWaterEfficiency_expCvegRoot, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootWaterEfficiency_expCvegRoot p_struct
    ## unpack land variables
    @unpack_land begin
        root_over ∈ land.rootWaterEfficiency
        root_water_efficiency ∈ land.states
        z_zero ∈ land.wCycleBase
        cVegRoot ∈ land.pools
    end
    ## calculate variables
    tmp_rootEff = max_root_water_efficiency -
                  (max_root_water_efficiency - min_root_water_efficiency) * (exp(-k_efficiency_cVegRoot * totalS(cVegRoot))) # root fraction/efficiency as a function of total carbon in root pools

    root_water_efficiency = inner_root_water(root_water_efficiency, land.pools.soilW, root_over, tmp_rootEff, helpers)
    ## pack land variables
    @pack_land root_water_efficiency => land.states
    return land
end

function inner_root_water(root_water_efficiency, land_pools_soilW, root_over, tmp_rootEff, helpers)
    for sl ∈ eachindex(land_pools_soilW)
        root_water_efficiency_sl = root_over[sl] * tmp_rootEff
        @rep_elem root_water_efficiency_sl => (root_water_efficiency, sl, :soilW)
    end
    return root_water_efficiency
end

@doc """
maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot]

# Parameters
$(SindbadParameters)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootWaterEfficiency_expCvegRoot

*Inputs*
 - soil_layer_thickness
 - land.pools.cEco
 - land.states.maxRootD [from rootWaterEfficiency_expCvegRoot]
 - max_root_depth [from rootWaterEfficiency_expCvegRoot]

*Outputs*
 - initiates land.states.root_water_efficiency as ones
 - land.states.root_water_efficiency as nPix;nZix for soilW
 - land.states.root_water_efficiency

# instantiate:
instantiate/instantiate time-invariant variables for rootWaterEfficiency_expCvegRoot


---

# Extended help

*References*

*Versions*
 - 1.0 on 28.04.2020  

*Created by:*
 - skoirala
"""
rootWaterEfficiency_expCvegRoot
