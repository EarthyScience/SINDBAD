export soilProperties_Saxton2006, kSaxton2006, soilParamsSaxton2006

#! format: off
@bounds @describe @units @with_kw struct soilProperties_Saxton2006{T1,T2,T3,T4,T5,TN} <: soilProperties
    DF::T1 = 1.0 | (0.9, 1.3) | "Density correction factor" | ""
    Rw::T2 = 0.0 | (0.0, 1.0) | "Weight fraction of gravel (decimal)" | "g g-1"
    matricSoilDensity::T3 = 2.65 | (2.5, 3.0) | "Matric soil density" | "g cm-3"
    gravelDensity::T4 = 2.65 | (2.5, 3.0) | "density of gravel material" | "g cm-3"
    EC::T5 = 36.0 | (30.0, 40.0) | "SElectrical conductance of a saturated soil extract" | "dS m-1 (dS/m = mili-mho cm-1)"
    a1::TN = -0.024 | (nothing, nothing) | "Saxton Parameters" | ""
    a2::TN = 0.487 | (nothing, nothing) | "Saxton Parameters" | ""
    a3::TN = 0.006 | (nothing, nothing) | "Saxton Parameters" | ""
    a4::TN = 0.005 | (nothing, nothing) | "Saxton Parameters" | ""
    a5::TN = 0.013 | (nothing, nothing) | "Saxton Parameters" | ""
    a6::TN = 0.068 | (nothing, nothing) | "Saxton Parameters" | ""
    a7::TN = 0.031 | (nothing, nothing) | "Saxton Parameters" | ""
    b1::TN = 0.14 | (nothing, nothing) | "Saxton Parameters" | ""
    b2::TN = 0.02 | (nothing, nothing) | "Saxton Parameters" | ""
    c1::TN = -0.251 | (nothing, nothing) | "Saxton Parameters" | ""
    c2::TN = 0.195 | (nothing, nothing) | "Saxton Parameters" | ""
    c3::TN = 0.011 | (nothing, nothing) | "Saxton Parameters" | ""
    c4::TN = 0.006 | (nothing, nothing) | "Saxton Parameters" | ""
    c5::TN = 0.027 | (nothing, nothing) | "Saxton Parameters" | ""
    c6::TN = 0.452 | (nothing, nothing) | "Saxton Parameters" | ""
    c7::TN = 0.299 | (nothing, nothing) | "Saxton Parameters" | ""
    d1::TN = 1.283 | (nothing, nothing) | "Saxton Parameters" | ""
    d2::TN = 0.374 | (nothing, nothing) | "Saxton Parameters" | ""
    d3::TN = 0.015 | (nothing, nothing) | "Saxton Parameters" | ""
    e1::TN = 0.278 | (nothing, nothing) | "Saxton Parameters" | ""
    e2::TN = 0.034 | (nothing, nothing) | "Saxton Parameters" | ""
    e3::TN = 0.022 | (nothing, nothing) | "Saxton Parameters" | ""
    e4::TN = 0.018 | (nothing, nothing) | "Saxton Parameters" | ""
    e5::TN = 0.027 | (nothing, nothing) | "Saxton Parameters" | ""
    e6::TN = 0.584 | (nothing, nothing) | "Saxton Parameters" | ""
    e7::TN = 0.078 | (nothing, nothing) | "Saxton Parameters" | ""
    f1::TN = 0.636 | (nothing, nothing) | "Saxton Parameters" | ""
    f2::TN = 0.107 | (nothing, nothing) | "Saxton Parameters" | ""
    g1::TN = -21.67 | (nothing, nothing) | "Saxton Parameters" | ""
    g2::TN = 27.93 | (nothing, nothing) | "Saxton Parameters" | ""
    g3::TN = 81.97 | (nothing, nothing) | "Saxton Parameters" | ""
    g4::TN = 71.12 | (nothing, nothing) | "Saxton Parameters" | ""
    g5::TN = 8.29 | (nothing, nothing) | "Saxton Parameters" | ""
    g6::TN = 14.05 | (nothing, nothing) | "Saxton Parameters" | ""
    g7::TN = 27.16 | (nothing, nothing) | "Saxton Parameters" | ""
    h1::TN = 0.02 | (nothing, nothing) | "Saxton Parameters" | ""
    h2::TN = 0.113 | (nothing, nothing) | "Saxton Parameters" | ""
    h3::TN = 0.70 | (nothing, nothing) | "Saxton Parameters" | ""
    i1::TN = 0.097 | (nothing, nothing) | "Saxton Parameters" | ""
    i2::TN = 0.043 | (nothing, nothing) | "Saxton Parameters" | ""
    n02::TN = 0.2 | (nothing, nothing) | "Saxton Parameters" | ""
    n2::TN = 2.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n24::TN = 24.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n3::TN = 3.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n33::TN = 33.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n36::TN = 36.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n1500::TN = 1500.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n1930::TN = 1930.0 | (nothing, nothing) | "Saxton Parameters" | ""

end
# b::T =  | nothing | "Saxton Parameters" | ""

function define(p_struct::soilProperties_Saxton2006, forcing, land, helpers)
    @unpack_soilProperties_Saxton2006 p_struct

    @unpack_land begin
        (𝟘, 𝟙, num_type, sNT) ∈ helpers.numbers
        (st_CLAY, st_ORGM, st_SAND) ∈ land.soilTexture
    end
    ## instantiate variables
    sp_α = zero(land.pools.soilW)
    sp_β = zero(land.pools.soilW)
    sp_kFC = zero(land.pools.soilW)
    sp_θFC = zero(land.pools.soilW)
    sp_ψFC = zero(land.pools.soilW)
    sp_kWP = zero(land.pools.soilW)
    sp_θWP = zero(land.pools.soilW)
    sp_ψWP = zero(land.pools.soilW)
    sp_kSat = zero(land.pools.soilW)
    sp_θSat = zero(land.pools.soilW)
    sp_ψSat = zero(land.pools.soilW)

    # generate the function handle to calculate soil hydraulic property
    unsatK = kSaxton2006::typeof(kSaxton2006)

    ## pack land variables
    @pack_land (sp_kFC, sp_kSat, unsatK, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP, n2, n3) => land.soilProperties
    return land
end


function precompute(p_struct::soilProperties_Saxton2006, forcing, land, helpers)
    @unpack_soilProperties_Saxton2006 p_struct

    @unpack_land begin
        (sp_kFC, sp_kSat, unsatK, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP) ∈ land.soilProperties
    end
    ## calculate variables
    # calculate & set the soil hydraulic properties for each layer
    for sl in eachindex(sp_α)
        (α, β, kSat, θSat, ψSat, kFC, θFC, ψFC, kWP, θWP, ψWP) = calcPropsSaxton2006(p_struct, land, helpers, sl)
        @rep_elem α => (sp_α, sl, :soilW)
        @rep_elem β => (sp_β, sl, :soilW)
        @rep_elem kFC => (sp_kFC, sl, :soilW)
        @rep_elem θFC => (sp_θFC, sl, :soilW)
        @rep_elem ψFC => (sp_ψFC, sl, :soilW)
        @rep_elem kWP => (sp_kWP, sl, :soilW)
        @rep_elem θWP => (sp_θWP, sl, :soilW)
        @rep_elem ψWP => (sp_ψWP, sl, :soilW)
        @rep_elem kSat => (sp_kSat, sl, :soilW)
        @rep_elem θSat => (sp_θSat, sl, :soilW)
        @rep_elem ψSat => (sp_ψSat, sl, :soilW)
    end

    ## pack land variables
    @pack_land (sp_kFC, sp_kSat, unsatK, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP) => land.soilProperties
    return land
end

@doc """
assigns the soil hydraulic properties based on Saxton; 2006 to land.soilProperties.sp_

# Parameters
$(PARAMFIELDS)

---

# compute:
Soil properties (hydraulic properties) using soilProperties_Saxton2006

*Inputs*
 - : texture-based Saxton parameters
 - calcSoilParamsSaxton2006: function to calculate hydraulic properties
 - info
 - land.soilTexture.sp_[CLAY/SAND]

*Outputs*
 - hydraulic conductivity [k], matric potention [ψ] & porosity  (θ) at saturation [Sat], field capacity [FC], & wilting point  (WP)
 - land.soilProperties.sp_[α/β]: properties of moisture-retention curves
 - land.soilProperties.sp_θFC/kFC/ψFC/sFC
 - land.soilProperties.sp_θSat/kSat/ψSat/sSat
 - land.soilProperties.sp_θWP/kWP/ψWP/sWP

# instantiate:
instantiate/instantiate time-invariant variables for soilProperties_Saxton2006


---

# Extended help

*References*
 - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by  texture & organic matter for hydrologic solutions.  Soil science society of America Journal, 70[5], 1569-1578.

*Versions*
 - 1.0 on 21.11.2019
 - 1.1 on 03.12.2019 [skoirala]: handling potentail vertical distribution of soil texture  

*Created by:*
 - Nuno Carvalhais [ncarval]
 - skoirala
"""
soilProperties_Saxton2006

"""
calculates the soil hydraulic conductivity for a given moisture based on Saxton; 2006

# Inputs:
 - land.pools.soilW[sl]
 - land.soilWBase.sp_[wSat/β/kSat]: hydraulic parameters for each soil layer

# Outputs:
 - K: the hydraulic conductivity at unsaturated land.pools.soilW [in mm/day]
 - is calculated using original equation if helpers.flags.useLookupK == 0.0
 - uses instantiated lookup table if helpers.flags.useLookupK == 1

# Modifies:

# Extended help

# References:
 - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by  texture & organic matter for hydrologic solutions.  Soil science society of America Journal, 70[5], 1569-1578.

# Versions:
 - 1.0 on 22.11.2019 [skoirala]:
 - 1.1 on 03.12.2019 [skoirala]: included the option to handle lookup table when set to true  from model_run.json  

# Created by:
 - skoirala

# Notes:
 - This function is a part of pSoil; but making the looking up table & setting the soil  properties is handled by soilWBase [by calling this function]
 - is also used by all approaches depending on kUnsat within time loop of coreTEM
"""
function kSaxton2006(land, helpers, sl)
    @unpack_land begin
        (n2, n3) ∈ land.soilProperties
        (p_β, p_kSat, p_wSat) ∈ land.soilWBase
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    ## calculate variables
    wSat = p_wSat[sl]
    θ_dos = (soilW[sl] + ΔsoilW[sl]) / wSat
    θ_dos = clamp_01(θ_dos)
    β = p_β[sl]
    kSat = p_kSat[sl]
    λ = 𝟙 / β
    K = kSat * ((θ_dos)^(n3 + (n2 / λ)))
    return K
end

"""
calculates the soil hydraulic properties based on Saxton 2006

# Inputs:
 - : texture-based parameters
 - info
 - land.soilTexture.sp_[CLAY/SAND]: in fraction
 - sl: soil layer to calculate property for

# Outputs:
 - hydraulic conductivity [k], matric potention [ψ] & porosity  (θ) at saturation [Sat], field capacity [FC], & wilting point  (WP)
 - properties of moisture-retention curves: (α & β)

# Modifies:

# Extended help

# References:
 - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by  texture & organic matter for hydrologic solutions.  Soil science society of America Journal, 70[5], 1569-1578.

# Versions:
 - 1.0 on 22.11.2019 [skoirala]:

# Created by:
 - skoirala

# Notes:
 - FC: Field Capacity moisture [33 kPa], #v  
 - PAW: Plant Avail. moisture [33-1500 kPa, matric soil], #v
 - PAWB: Plant Avail. moisture [33-1500 kPa, bulk soil], #v
 - SAT: Saturation moisture [0 kPa], #v
 - WP: Wilting point moisture [1500 kPa], #v
"""
function calcPropsSaxton2006(p_struct::soilProperties_Saxton2006, land, helpers, sl)

    @unpack_soilProperties_Saxton2006 p_struct
    @unpack_land begin
        (𝟘, 𝟙, num_type, sNT) ∈ helpers.numbers
        (st_CLAY, st_ORGM, st_SAND) ∈ land.soilTexture
    end

    CLAY = st_CLAY[sl]
    SAND = st_SAND[sl]
    ORGM = st_ORGM[sl]
    # ORGM = sp_ORGM[sl]
    # ORGM = 𝟘
    # CLAY = CLAY
    # SAND = SAND
    # ORGM = ORGM
    ## Moisture regressions
    # θ_1500t: 1500 kPa moisture; first solution; #v
    # θ_1500: 1500 kPa moisture; #v
    θ_1500t = a1 * SAND + a2 * CLAY + a3 * ORGM + a4 * (SAND * ORGM) - a5 * (CLAY * ORGM) + a6 * (SAND * CLAY) + a7
    θ_1500 = θ_1500t + (b1 * θ_1500t - b2)
    # θ_33t: 33 kPa moisture; first solution; #v
    # θ_33: 33 kPa moisture; normal density; #v
    θ_33t = c1 * SAND + c2 * CLAY + c3 * ORGM + c4 * (SAND * ORGM) - c5 * (CLAY * ORGM) + c6 * (SAND * CLAY) + c7
    θ_33 = θ_33t + (d1 * (θ_33t)^n2 - d2 * θ_33t - d3)
    # θ_s_33t: SAT-33 kPa moisture; first solution; #v
    # θ_s_33: SAT-33 kPa moisture; normal density #v
    θ_s_33t = e1 * SAND + e2 * CLAY + e3 * ORGM - e4 * (SAND * ORGM) - e5 * (CLAY * ORGM) - e6 * (SAND * CLAY) + e7
    θ_s_33 = θ_s_33t + (f1 * θ_s_33t - f2)
    # ψ_et: Tension at air entry; first solution; kPa
    # ψ_e: Tension at air entry [bubbling pressure], kPa
    ψ_et = abs(g1 * SAND - g2 * CLAY - g3 * θ_s_33 + g4 * (SAND * θ_s_33) + g5 * (CLAY * θ_s_33) - g6 * (SAND * CLAY) + g7)
    ψ_e = abs(ψ_et + (h1 * (ψ_et^n2) - h2 * ψ_et - h3))
    # θ_s: Saturated moisture [0 kPa], normal density, #v
    # rho_N: Normal density; g cm-3
    θ_s = θ_33 + θ_s_33 - i1 * SAND + i2
    rho_N = (𝟙 - θ_s) * gravelDensity
    ## Density effects
    # rho_DF: Adjusted density; g cm-3
    # θ_s_DF: Saturated moisture [0 kPa], adjusted density, #v
    # θ_33_DF: 33 kPa moisture; adjusted density; #v
    # θ_s_33_DF: SAT-33 kPa moisture; adjusted density; #v
    # DF: Density adjustment Factor [0.9-1.3]
    rho_DF = rho_N * DF
    # θ_s_DF = 1 - (rho_DF / gravelDensity); # original but does not include θ_s
    θ_s_DF = θ_s * (𝟙 - (rho_DF / gravelDensity)) # may be includes θ_s
    θ_33_DF = θ_33 - n02 * (θ_s - θ_s_DF)
    θ_1500_DF = θ_1500 - n02 * (θ_s - θ_s_DF)
    θ_s_33_DF = θ_s_DF - θ_33_DF
    ## Moisture-Tension
    # A, B: Coefficients of moisture-tension, Eq. [11]
    # ψ_θ: Tension at moisture θ; kPa
    B = (log(n1500) - log(n33)) / (log(θ_33) - log(θ_1500))
    A = exp(log(n33) + B * log(θ_33))
    # ψ_θ = A * ((θ) ^ (-B))
    # ψ_33 = 33.0 - ((θ - θ_33) * (33.0 - ψ_e)) / (θ_s - θ_33)
    ## Moisture-Conductivity
    # λ: Slope of logarithmic tension-moisture curve
    # Ks: Saturated conductivity [matric soil], mm h-1
    # K_θ: Unsaturated conductivity at moisture θ; mm h-1
    λ = 𝟙 / B
    Ks = n1930 * ((θ_s - θ_33)^(n3 - λ)) * n24
    # K_θ = Ks * ((θ / θ_s) ^ (3 + (2 / λ)))
    ## Gravel Effects
    # rho_B: Bulk soil density [matric plus gravel], g cm-3
    # αRho: Matric soil density/gravel density [gravelDensity] = rho/2.65
    # Rv: Volume fraction of gravel [decimal], g cm -3
    # Rw: Weight fraction of gravel [decimal], g g-1
    # Kb: Saturated conductivity [bulk soil], mm h-1
    αRho = matricSoilDensity / gravelDensity
    Rv = (αRho * Rw) / (𝟙 - Rw * (𝟙 - αRho))
    rho_B = rho_N * (𝟙 - Rv) + Rv * gravelDensity
    # PAW_B = PAW * (𝟙 - Rv)
    Kb = Ks * ((𝟙 - Rw) / (𝟙 - Rw * (𝟙 - (n3 * αRho / n2))))
    ## Salinity Effects
    # ϕ_o: Osmotic potential at θ = θ_s; kPa
    # ϕ_o_θ: Osmotic potential at θ < θ_s; kPa
    # EC: Electrical conductance of a saturated soil extract, dS m-1 [dS/m = mili-mho cm-1]
    phi_o = n36 * EC
    # ϕ_o_θ = (θ_s / θ) * n36 / EC
    ## Assign the variables for returning
    α = A
    β = B
    # θSat = θ_s_DF
    θSat = θ_s
    kSat = Kb
    ψSat = 𝟘
    # θFC = θ_33_DF
    θFC = θ_33
    kFC = kSat * ((θFC / θSat)^(n3 + (n2 / λ)))
    ψFC = n33
    # θWP = θ_1500_DF
    θWP = θ_1500
    ψWP = n1500
    kWP = kSat * ((θWP / θSat)^(n3 + (n2 / λ)))

    ## pack land variables
    return α, β, kSat, θSat, ψSat, kFC, θFC, ψFC, kWP, θWP, ψWP
end
