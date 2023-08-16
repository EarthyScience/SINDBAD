export PET_Lu2005

#! format: off
@bounds @describe @units @with_kw struct PET_Lu2005{T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15} <: PET
    α::T1 = 1.26 | (0.1, 2.0) | "calibration constant: α = 1.26 for wet or humid" | ""
    svp_1::T2 = 0.200 | (nothing, nothing) | "saturation vapor pressure temperature curve parameter 1" | ""
    svp_2::T3 = 0.00738 | (nothing, nothing) | "saturation vapor pressure temperature curve parameter 2" | ""
    svp_3::T4 = 0.8072 | (nothing, nothing) | "saturation vapor pressure temperature curve parameter 3" | ""
    svp_4::T5 = 7.0 | (nothing, nothing) | "saturation vapor pressure temperature curve parameter 4" | ""
    svp_5::T6 = 0.000116 | (nothing, nothing) | "saturation vapor pressure temperature curve parameter 5" | ""
    sh_cp::T7 = 0.001013 | (nothing, nothing) | "specific heat of moist air at constant pressure (1.013 kJ/kg/°C)" | "MJ/kg/°C"
    elev::T8 = 0.0 | (0.0, 8848.0) | "elevation" | "m"
    pres_sl::T9 = 101.3 | (0.0, 101.3) | "atmospheric pressure at sea level" | "kpa"
    pres_elev::T10 = 0.01055 | (nothing, nothing) | "rate of change of atmospheric pressure with elevation" | "kpa/m"
    λ_base::T11 = 2.501 | (nothing, nothing) | "latent heat of vaporization" | "MJ/kg"
    λ_tair::T12 = 0.002361 | (nothing, nothing) | "rate of change of latent heat of vaporization with temperature" | "MJ/kg/°C"
    γ_resistance::T13 = 0.622 | (nothing, nothing) | "ratio of canopy resistance to atmospheric resistance" | ""
    Δt::T14 = 2.0 | (nothing, nothing) | "time delta for calculation of G" | "day"
    G_base::T15 = 4.2 | (nothing, nothing) | "base groundheat flux" | ""
end
#! format: on

function define(p_struct::PET_Lu2005, forcing, land, helpers)
    ## unpack forcing
    @unpack_PET_Lu2005 p_struct
    @unpack_forcing Tair ∈ forcing
    PET = land.wCycleBase.z_zero
    ## calculate variables
    Tair_prev = Tair

    ## pack land variables
    @pack_land (PET, Tair_prev) => land.fluxes
    return land
end

function compute(p_struct::PET_Lu2005, forcing, land, helpers)
    ## unpack parameters
    @unpack_PET_Lu2005 p_struct
    ## unpack forcing
    @unpack_forcing (Rn, Tair) ∈ forcing

    @unpack_land begin
        Tair_prev ∈ land.fluxes
        (z_zero, o_one) ∈ land.wCycleBase
    end

    ## calculate variables
    # slope of the saturation vapor pressure temperature curve [kPa/°C]
    Δ = svp_1 * (svp_2 * Tair + svp_3)^svp_4 - svp_5

    # atmp is the atmospheric pressure [kPa], elev = elevation
    atmp = pres_sl - pres_elev * elev

    # λ is the latent heat of vaporization [MJ/kg]
    λ = λ_base - λ_tair * Tair

    # γ is the the psychrometric constant modified by the ratio of
    # canopy resistance to atmospheric resistance [kPa/°C].
    γ = sh_cp * atmp / (γ_resistance * λ)

    # G is the heat flux density to the ground [MJ/m^2/day]
    # G = 4.2[T[i+1]-T[i-1]]/dt → adopted to T[i]-T[i-1] by skoirala
    # G = 4.2 * (Tair_ip1 - Tair_im1) / dt
    # where Ti is the mean air temperature [°C] for the period i; &
    # dt the difference of time [days]..
    ΔTair = Tair - Tair_prev
    G = G_base * (ΔTair) / Δt
    G = z_zero #@needscheck: current G is set to zero because the original formula looked at tomorrow's temperature, and we only have today and yesterday's data available during a model run
    PET = (α * (Δ / (Δ + γ)) * (Rn - G)) / λ
    PET = maxZero(PET)

    Tair_prev = Tair

    ## pack land variables
    @pack_land (PET, Tair_prev) => land.fluxes
    return land
end

@doc """
Calculates the value of land.fluxes.PET from the forcing variables

# Parameters
$(SindbadParameters)

---

# compute:
Set potential evapotranspiration using PET_Lu2005

*Inputs*
 - forcing.Rn: Net radiation
 - forcing.Tair: Air temperature

*Outputs*
 - land.fluxes.PET: the value of PET for current time step

---

# Extended help

*References*
 - Lu

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
PET_Lu2005
