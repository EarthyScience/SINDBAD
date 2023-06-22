export rootFraction_constant

#! format: off
@bounds @describe @units @with_kw struct rootFraction_constant{T1} <: rootFraction
    constantRootFrac::T1 = 0.05 | (0.01, 0.15) | "root fraction" | ""
end
#! format: on

function define(o::rootFraction_constant, forcing, land, helpers)
    @unpack_rootFraction_constant o
    @unpack_land soilLayerThickness ∈ land.soilWBase
    @unpack_land soilW ∈ land.pools
    cumulativeDepths = cumsum(soilLayerThickness)
    ## instantiate
    p_fracRoot2SoilD = zero(land.pools.soilW) .+ helpers.numbers.𝟙

    ## pack land variables
    @pack_land begin
        p_fracRoot2SoilD => land.rootFraction
        cumulativeDepths => land.rootFraction
    end

    return land
end

function compute(o::rootFraction_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootFraction_constant o

    ## unpack land variables
    @unpack_land begin
        soilLayerThickness ∈ land.soilWBase
        (p_fracRoot2SoilD, cumulativeDepths) ∈ land.rootFraction
        maxRootDepth ∈ land.states
        𝟘 ∈ helpers.numbers
    end

    ## calculate variables
    # cumSum!(soilLayerThickness, cumulativeDepths)
    # maxRootDepth = min(maxRootDepth, sum(soilDepths)); # maximum rootingdepth
    for sl ∈ eachindex(land.pools.soilW)
        soilcumuD = cumulativeDepths[sl]
        rootOver = maxRootDepth - soilcumuD
        rootFrac = rootOver > 𝟘 ? constantRootFrac : 𝟘
        @rep_elem rootFrac => (p_fracRoot2SoilD, sl, :soilW)
    end

    ## pack land variables
    @pack_land p_fracRoot2SoilD => land.rootFraction
    return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_constant

*Inputs*
 - land.states.maxRootD

*Outputs*
 - land.rootFraction.p_fracRoot2SoilD

# instantiate:
instantiate/instantiate time-invariant variables for rootFraction_constant


---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
rootFraction_constant
