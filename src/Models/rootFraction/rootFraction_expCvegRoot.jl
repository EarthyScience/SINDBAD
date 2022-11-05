export rootFraction_expCvegRoot

@bounds @describe @units @with_kw struct rootFraction_expCvegRoot{T1,T2,T3} <: rootFraction
    k_cVegRoot::T1 = 0.02 | (0.001, 0.3) | "rate constant of exponential relationship" | "m2/kgC (inverse of carbon storage)"
    fracRoot2SoilD_max::T2 = 0.95 | (0.7, 0.98) | "maximum root water uptake capacity" | ""
    fracRoot2SoilD_min::T3 = 0.1 | (0.05, 0.3) | "minimum root water uptake threshold" | ""
end

function precompute(o::rootFraction_expCvegRoot, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)
    @unpack_rootFraction_expCvegRoot o
    @unpack_land begin
        soilLayerThickness ∈ land.soilWBase
        maxRootDepth ∈ land.states
    end
    ## instantiate variables
    p_fracRoot2SoilD = ones(helpers.numbers.numType, length(land.pools.soilW))
    rootOver = zeros(helpers.numbers.numType, length(land.pools.soilW))
    cumulativeDepths = cumsum(soilLayerThickness)
    rootOver .= maxRootDepth .- cumulativeDepths
    ## pack land variables
    @pack_land begin
        (p_fracRoot2SoilD, cumulativeDepths, rootOver) => land.rootFraction
    end
    return land
end

function compute(o::rootFraction_expCvegRoot, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters
    @unpack_rootFraction_expCvegRoot o
    ## unpack land variables
    @unpack_land begin
        soilLayerThickness ∈ land.soilWBase
        (p_fracRoot2SoilD, cumulativeDepths, rootOver) ∈ land.rootFraction
        𝟘 ∈ helpers.numbers
        cVegRoot ∈ land.pools
    end
    ## calculate variables
    tmp_rootFrac = (fracRoot2SoilD_max - (fracRoot2SoilD_max - fracRoot2SoilD_min) * (exp(-k_cVegRoot * sum(cVegRoot)))) # root fraction/efficiency as a function of total carbon in root pools

    for k in eachindex(rootOver)
        p_fracRoot2SoilD[k] =  rootOver[k] > 𝟘 ? tmp_rootFrac : 𝟘
    end
    return land
end

@doc """
Precomputation for maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot]

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_expCvegRoot

*Inputs*
 - soilLayerThickness
 - land.pools.cEco
 - land.states.maxRootD [from rootFraction_expCvegRoot]
 - maxRootDepth [from rootFraction_expCvegRoot]

*Outputs*
 - initiates land.rootFraction.p_fracRoot2SoilD as ones
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW
 - land.rootFraction.p_fracRoot2SoilD

# precompute:
precompute/instantiate time-invariant variables for rootFraction_expCvegRoot


---

# Extended help

*References*

*Versions*
 - 1.0 on 28.04.2020  

*Created by:*
 - skoirala
"""
rootFraction_expCvegRoot