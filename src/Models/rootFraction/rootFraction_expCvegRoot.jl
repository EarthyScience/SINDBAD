export rootFraction_expCvegRoot

#! format: off
@bounds @describe @units @with_kw struct rootFraction_expCvegRoot{T1,T2,T3} <: rootFraction
    k_cVegRoot::T1 = 0.02 | (0.001, 0.3) | "rate constant of exponential relationship" | "m2/kgC (inverse of carbon storage)"
    frac_root_to_soil_depth_max::T2 = 0.95 | (0.7, 0.98) | "maximum root water uptake capacity" | ""
    frac_root_to_soil_depth_min::T3 = 0.1 | (0.05, 0.3) | "minimum root water uptake threshold" | ""
end
#! format: on

function define(p_struct::rootFraction_expCvegRoot, forcing, land, helpers)
    @unpack_rootFraction_expCvegRoot p_struct
    @unpack_land begin
        soil_layer_thickness ∈ land.soilWBase
    end
    ## instantiate variables
    p_frac_root_to_soil_depth = zero(land.pools.soilW) .+ one(first(land.pools.soilW))
    cumulative_soil_depths = cumsum(soil_layer_thickness)
    ## pack land variables
    @pack_land begin
        (p_frac_root_to_soil_depth, cumulative_soil_depths) => land.rootFraction
    end
    return land
end

function compute(p_struct::rootFraction_expCvegRoot, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootFraction_expCvegRoot p_struct
    ## unpack land variables
    @unpack_land begin
        soil_layer_thickness ∈ land.soilWBase
        (p_frac_root_to_soil_depth, cumulative_soil_depths) ∈ land.rootFraction
        max_root_depth ∈ land.states
        z_zero ∈ land.wCycleBase
        cVegRoot ∈ land.pools
    end
    ## calculate variables
    tmp_rootFrac = frac_root_to_soil_depth_max -
                   (frac_root_to_soil_depth_max - frac_root_to_soil_depth_min) * (exp(-k_cVegRoot * addS(cVegRoot))) # root fraction/efficiency as a function of total carbon in root pools

    for sl ∈ eachindex(land.pools.soilW)
        soilcumuD = cumulative_soil_depths[sl]
        rootOver = max_root_depth - soilcumuD
        rootFrac = rootOver > z_zero ? tmp_rootFrac : z_zero
        @rep_elem rootFrac => (p_frac_root_to_soil_depth, sl, :soilW)
    end
    ## pack land variables
    @pack_land p_frac_root_to_soil_depth => land.rootFraction
    return land
end

@doc """
maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot]

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_expCvegRoot

*Inputs*
 - soil_layer_thickness
 - land.pools.cEco
 - land.states.maxRootD [from rootFraction_expCvegRoot]
 - max_root_depth [from rootFraction_expCvegRoot]

*Outputs*
 - initiates land.rootFraction.p_frac_root_to_soil_depth as ones
 - land.rootFraction.p_frac_root_to_soil_depth as nPix;nZix for soilW
 - land.rootFraction.p_frac_root_to_soil_depth

# instantiate:
instantiate/instantiate time-invariant variables for rootFraction_expCvegRoot


---

# Extended help

*References*

*Versions*
 - 1.0 on 28.04.2020  

*Created by:*
 - skoirala
"""
rootFraction_expCvegRoot
