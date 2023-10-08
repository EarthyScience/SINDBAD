export WUE_expVPDDayCo2

#! format: off
@bounds @describe @units @with_kw struct WUE_expVPDDayCo2{T1,T2,T3,T4,T5} <: WUE
    WUE_one_hpa::T1 = 9.2 | (2.0, 20.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
    κ::T2 = 0.4 | (0.06, 0.7) | "" | "kPa-1"
    base_ambient_CO2::T3 = 380.0 | (300.0, 500.0) | "" | "ppm"
    sat_ambient_CO2::T4 = 500.0 | (10.0, 2000.0) | "" | "ppm"
    kpa_to_hpa::T5 = 10.0 | (-Inf, Inf) | "unit conversion kPa to hPa" | ""
end
#! format: on

function compute(p_struct::WUE_expVPDDayCo2, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_WUE_expVPDDayCo2 p_struct
    @unpack_forcing f_VPD_day ∈ forcing

    ## unpack land variables
    @unpack_land begin
        ambient_CO2 ∈ land.states
    end

    ## calculate variables
    WUENoCO2 = WUE_one_hpa * exp(κ * -(f_VPD_day))
    fCO2_CO2 = one(ambient_CO2) + (ambient_CO2 - base_ambient_CO2) / (ambient_CO2 - base_ambient_CO2 + sat_ambient_CO2)
    WUE = WUENoCO2 * fCO2_CO2

    ## pack land variables
    @pack_land (WUE, WUENoCO2) => land.WUE
    return land
end

@doc """
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# Parameters
$(SindbadParameters)

---

# compute:
Estimate wue using WUE_expVPDDayCo2

*Inputs*
 - WUEat1hPa: the VPD at 1 hpa
 - forcing.f_VPD_day: daytime mean VPD [kPa]

*Outputs*
 - land.WUE.WUENoCO2: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O] without co2 effect

---

# Extended help

*References*

*Versions*
 - 1.0 on 31.03.2021 [skoirala]

*Created by:*
 - skoirala
"""
WUE_expVPDDayCo2
