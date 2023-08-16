export soilProperties_Saxton1986, unsatK, soilParamsSaxton1986

struct kSaxton1986 end

#! format: off
@bounds @describe @units @with_kw struct soilProperties_Saxton1986{T1,T2,T3,TN} <: soilProperties
    ψFC::T1 = 33.0 | (30.0, 35.0) | "matric potential at field capacity" | "kPa"
    ψWP::T2 = 1500.0 | (1000.0, 1800.0) | "matric potential at wilting point" | "kPa"
    ψSat::T3 = 0.0 | (0.0, 5.0) | "matric potential at saturation" | "kPa"
    a1::TN = -4.396 | (nothing, nothing) | "Saxton Parameters" | ""
    a2::TN = -0.0715 | (nothing, nothing) | "Saxton Parameters" | ""
    a3::TN = -0.000488 | (nothing, nothing) | "Saxton Parameters" | ""
    a4::TN = -4.285e-05 | (nothing, nothing) | "Saxton Parameters" | ""
    b1::TN = -3.14 | (nothing, nothing) | "Saxton Parameters" | ""
    b2::TN = -0.00222 | (nothing, nothing) | "Saxton Parameters" | ""
    b3::TN = -3.484e-05 | (nothing, nothing) | "Saxton Parameters" | ""
    c1::TN = 0.332 | (nothing, nothing) | "Saxton Parameters" | ""
    c2::TN = -0.0007251 | (nothing, nothing) | "Saxton Parameters" | ""
    c3::TN = 0.1276 | (nothing, nothing) | "Saxton Parameters" | ""
    d1::TN = -0.108 | (nothing, nothing) | "Saxton Parameters" | ""
    d2::TN = 0.341 | (nothing, nothing) | "Saxton Parameters" | ""
    e1::TN = 2.778e-6 | (nothing, nothing) | "Saxton Parameters" | ""
    e2::TN = 12.012 | (nothing, nothing) | "Saxton Parameters" | ""
    e3::TN = -0.0755 | (nothing, nothing) | "Saxton Parameters" | ""
    e4::TN = -3.895 | (nothing, nothing) | "Saxton Parameters" | ""
    e5::TN = 0.03671 | (nothing, nothing) | "Saxton Parameters" | ""
    e6::TN = -0.1103 | (nothing, nothing) | "Saxton Parameters" | ""
    e7::TN = 0.00087546 | (nothing, nothing) | "Saxton Parameters" | ""
    f1::TN = 2.302 | (nothing, nothing) | "Saxton Parameters" | ""
    n2::TN = 2.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n24::TN = 24.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n10::TN = 10.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n100::TN = 100.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n1000::TN = 1000.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n1500::TN = 1000.0 | (nothing, nothing) | "Saxton Parameters" | ""
    n3600::TN = 3600.0 | (nothing, nothing) | "Saxton Parameters" | ""

end

function define(p_struct::soilProperties_Saxton1986, forcing, land, helpers)
    @unpack_soilProperties_Saxton1986 p_struct

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

function precompute(p_struct::soilProperties_Saxton1986, forcing, land, helpers)
    ## unpack parameters
    @unpack_soilProperties_Saxton1986 p_struct

    ## unpack land variables
    @unpack_land (sp_α, sp_β, sp_kFC, sp_θFC, sp_ψFC, sp_kWP, sp_θWP, sp_ψWP, sp_kSat, sp_θSat, sp_ψSat) ∈ land.soilProperties

    ## calculate variables
    # number of layers & creation of arrays
    # calculate & set the soil hydraulic properties for each layer
    for sl in eachindex(land.pools.soilW)
        (α, β, kFC, θFC, ψFC) = calcPropsSaxton1986(p_struct, land, helpers, sl, ψFC)
        (_, _, kWP, θWP, ψWP) = calcPropsSaxton1986(p_struct, land, helpers, sl, ψWP)
        (_, _, kSat, θSat, ψSat) = calcPropsSaxton1986(p_struct, land, helpers, sl, ψSat)
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
        (st_CLAY, st_SAND) ∈ land.soilTexture
        soil_layer_thickness ∈ land.soilWBase
        (n100, n1000, n2, n24, n3600, e1, e2, e3, e4, e5, e6, e7) ∈ land.soilProperties
        soilW ∈ land.pools
    end

    ## calculate variables
    CLAY = st_CLAY[sl] * n100
    SAND = st_SAND[sl] * n100
    soilD = soil_layer_thickness[sl]
    θ = soilW[sl] / soilD
    K = e1 * (exp(e2 + e3 * SAND + (e4 + e5 * SAND + e6 * CLAY + e7 * CLAY^n2) * (o_one / θ))) * n1000 * n3600 * n24

    ## pack land variables
    return K
end

"""
calculates the soil hydraulic properties based on Saxton 1986

# Extended help
"""
function calcPropsSaxton1986(p_struct::soilProperties_Saxton1986, land, helpers, sl, WT)
    @unpack_soilProperties_Saxton1986 p_struct

    @unpack_land begin
        (z_zero, o_one) ∈ land.wCycleBase
        (st_CLAY, st_SAND) ∈ land.soilTexture
    end

    ## calculate variables
    # CONVERT SAND AND CLAY TO PERCENTAGES
    CLAY = st_CLAY[sl] * n100
    SAND = st_SAND[sl] * n100
    # Equations
    A = exp(a1 + a2 * CLAY + a3 * SAND^n2 + a4 * SAND^n2 * CLAY) * n100
    B = b1 + b2 * CLAY^n2 + b3 * SAND^n2 * CLAY
    # soil matric potential; ψ; kPa
    ψ = WT
    # soil moisture content at saturation [m^3/m^3]
    θ_s = c1 + c2 * SAND + c3 * log10(CLAY)
    # air entry pressure [kPa]
    ψ_e = abs(n100 * (d1 + d2 * θ_s))
    # θ = ones(typeof(CLAY), size(CLAY))
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
    K = e1 * (exp(e2 + e3 * SAND + (e4 + e5 * SAND + e6 * CLAY + e7 * CLAY^n2) * (o_one / θ))) * n1000 * n3600 * n24
    α = A
    β = B
    ## pack land variables
    return α, β, K, θ, ψ
end
