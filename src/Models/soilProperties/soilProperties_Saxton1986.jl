export soilProperties_Saxton1986, unsatK, soilParamsSaxton1986

struct kSaxton1986 end

#! format: off
@bounds @describe @units @with_kw struct soilProperties_Saxton1986{T1,T2,T3,TN} <: soilProperties
    ψFC::T1 = 33.0 | (30.0, 35.0) | "matric potential at field capacity" | "kPa"
    ψWP::T2 = 1500.0 | (1000.0, 1800.0) | "matric potential at wilting point" | "kPa"
    ψSat::T3 = 0.0 | (0.0, 5.0) | "matric potential at saturation" | "kPa"
    a1::TN = -4.396 | (-Inf, Inf) | "Saxton Parameters" | ""
    a2::TN = -0.0715 | (-Inf, Inf) | "Saxton Parameters" | ""
    a3::TN = -0.000488 | (-Inf, Inf) | "Saxton Parameters" | ""
    a4::TN = -4.285e-05 | (-Inf, Inf) | "Saxton Parameters" | ""
    b1::TN = -3.14 | (-Inf, Inf) | "Saxton Parameters" | ""
    b2::TN = -0.00222 | (-Inf, Inf) | "Saxton Parameters" | ""
    b3::TN = -3.484e-05 | (-Inf, Inf) | "Saxton Parameters" | ""
    c1::TN = 0.332 | (-Inf, Inf) | "Saxton Parameters" | ""
    c2::TN = -0.0007251 | (-Inf, Inf) | "Saxton Parameters" | ""
    c3::TN = 0.1276 | (-Inf, Inf) | "Saxton Parameters" | ""
    d1::TN = -0.108 | (-Inf, Inf) | "Saxton Parameters" | ""
    d2::TN = 0.341 | (-Inf, Inf) | "Saxton Parameters" | ""
    e1::TN = 2.778e-6 | (-Inf, Inf) | "Saxton Parameters" | ""
    e2::TN = 12.012 | (-Inf, Inf) | "Saxton Parameters" | ""
    e3::TN = -0.0755 | (-Inf, Inf) | "Saxton Parameters" | ""
    e4::TN = -3.895 | (-Inf, Inf) | "Saxton Parameters" | ""
    e5::TN = 0.03671 | (-Inf, Inf) | "Saxton Parameters" | ""
    e6::TN = -0.1103 | (-Inf, Inf) | "Saxton Parameters" | ""
    e7::TN = 0.00087546 | (-Inf, Inf) | "Saxton Parameters" | ""
    f1::TN = 2.302 | (-Inf, Inf) | "Saxton Parameters" | ""
    n2::TN = 2.0 | (-Inf, Inf) | "Saxton Parameters" | ""
    n24::TN = 24.0 | (-Inf, Inf) | "Saxton Parameters" | ""
    n10::TN = 10.0 | (-Inf, Inf) | "Saxton Parameters" | ""
    n100::TN = 100.0 | (-Inf, Inf) | "Saxton Parameters" | ""
    n1000::TN = 1000.0 | (-Inf, Inf) | "Saxton Parameters" | ""
    n1500::TN = 1000.0 | (-Inf, Inf) | "Saxton Parameters" | ""
    n3600::TN = 3600.0 | (-Inf, Inf) | "Saxton Parameters" | ""

end

function define(params::soilProperties_Saxton1986, forcing, land, helpers)
    @unpack_soilProperties_Saxton1986 params

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

    unsat_k_model = kSaxton1986()

    ## pack land variables
    @pack_land begin
        (sp_kFC, sp_kSat, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP, unsat_k_model) => land.soilProperties
        (n100, n1000, n2, n24, n3600, e1, e2, e3, e4, e5, e6, e7) => land.soilProperties
    end
    return land
end

function precompute(params::soilProperties_Saxton1986, forcing, land, helpers)
    ## unpack parameters
    @unpack_soilProperties_Saxton1986 params

    ## unpack land variables
    @unpack_land (sp_α, sp_β, sp_kFC, sp_θFC, sp_ψFC, sp_kWP, sp_θWP, sp_ψWP, sp_kSat, sp_θSat, sp_ψSat) ∈ land.soilProperties

    ## calculate variables
    # number of layers & creation of arrays
    # calculate & set the soil hydraulic properties for each layer
    for sl in eachindex(land.pools.soilW)
        (α, β, kFC, θFC, ψFC) = calcPropsSaxton1986(params, land, helpers, sl, ψFC)
        (_, _, kWP, θWP, ψWP) = calcPropsSaxton1986(params, land, helpers, sl, ψWP)
        (_, _, kSat, θSat, ψSat) = calcPropsSaxton1986(params, land, helpers, sl, ψSat)
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
    @pack_land begin
        (sp_kFC, sp_kSat, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP) => land.soilProperties
    end
    return land
end

@doc """
assigns the soil hydraulic properties based on Saxton; 1986 to land.soilProperties.sp_

# Parameters
$(SindbadParameters)

# instantiate:
instantiate/instantiate time-invariant variables for soilProperties_Saxton1986


---

# Extended help
"""
soilProperties_Saxton1986

"""
calculates the soil hydraulic conductivity for a given moisture based on Saxton; 1986

# Extended help
"""
function unsatK(land, helpers, sl, ::kSaxton1986)
    @unpack_land begin
        (st_clay, st_sand) ∈ land.soilTexture
        soil_layer_thickness ∈ land.soilWBase
        (n100, n1000, n2, n24, n3600, e1, e2, e3, e4, e5, e6, e7) ∈ land.soilProperties
        soilW ∈ land.pools
    end

    ## calculate variables
    clay = st_clay[sl] * n100
    sand = st_sand[sl] * n100
    soilD = soil_layer_thickness[sl]
    θ = soilW[sl] / soilD
    K = e1 * (exp(e2 + e3 * sand + (e4 + e5 * sand + e6 * clay + e7 * clay^n2) * (o_one / θ))) * n1000 * n3600 * n24

    ## pack land variables
    return K
end

"""
calculates the soil hydraulic properties based on Saxton 1986

# Extended help
"""
function calcPropsSaxton1986(params::soilProperties_Saxton1986, land, helpers, sl, WT)
    @unpack_soilProperties_Saxton1986 params

    @unpack_land begin
        (z_zero, o_one) ∈ land.wCycleBase
        (st_clay, st_sand) ∈ land.soilTexture
    end

    ## calculate variables
    # CONVERT sand AND clay TO PERCENTAGES
    clay = st_clay[sl] * n100
    sand = st_sand[sl] * n100
    # Equations
    A = exp(a1 + a2 * clay + a3 * sand^n2 + a4 * sand^n2 * clay) * n100
    B = b1 + b2 * clay^n2 + b3 * sand^n2 * clay
    # soil matric potential; ψ; kPa
    ψ = WT
    # soil moisture content at saturation [m^3/m^3]
    θ_s = c1 + c2 * sand + c3 * log10(clay)
    # air entry pressure [kPa]
    ψ_e = abs(n100 * (d1 + d2 * θ_s))
    # θ = ones(typeof(clay), size(clay))
    θ = o_one
    if (ψ >= n10 & ψ <= n1500)
        θ = ψ / A^(o_one / B)
    end
    # clear ndx
    if (ψ >= ψ_e & ψ < n10)
        # θ at 10 kPa [m^3/m^3]
        θ_10 = exp((f1 - log(A)) / B)
        # ---------------------------------------------------------------------
        # ψ = 10.0 - (θ - θ_10) * (10.0 - # ψ_e) / (θ_s - θ_10)
        # ---------------------------------------------------------------------
        θ = θ_10 + (n10 - ψ) * (θ_s - θ_10) / (n10 - ψ_e)
    end
    # clear ndx
    if (ψ >=z_zero& ψ < ψ_e)
        θ = θ_s
    end
    # clear ndx
    # hydraulic conductivity [mm/day]: original equation for mm/s
    K = e1 * (exp(e2 + e3 * sand + (e4 + e5 * sand + e6 * clay + e7 * clay^n2) * (o_one / θ))) * n1000 * n3600 * n24
    α = A
    β = B
    ## pack land variables
    return α, β, K, θ, ψ
end
