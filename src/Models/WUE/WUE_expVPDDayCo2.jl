export WUE_expVPDDayCo2

#! format: off
@bounds @describe @units @with_kw struct WUE_expVPDDayCo2{T1,T2,T3,T4,T5} <: WUE
    WUEatOnehPa::T1 = 9.2 | (2.0, 20.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
    κ::T2 = 0.4 | (0.06, 0.7) | "" | "kPa-1"
    Ca0::T3 = 380.0 | (300.0, 500.0) | "" | "ppm"
    Cm::T4 = 500.0 | (10.0, 2000.0) | "" | "ppm"
    kpa_to_hpa::T5 = 10.0 | (-Inf, Inf) | "unit conversion kPa to hPa" | ""
end
#! format: on

function compute(p_struct::WUE_expVPDDayCo2, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_WUE_expVPDDayCo2 p_struct
    @unpack_forcing VPDDay ∈ forcing

    ## unpack land variables
    @unpack_land begin
        ambient_CO2 ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
    end

    ## calculate variables
    WUENoCO2 = WUEatOnehPa * exp(κ * -(VPDDay))
    fCO2_CO2 = o_one + (ambient_CO2 - Ca0) / (ambient_CO2 - Ca0 + Cm)
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
 - forcing.VPDDay: daytime mean VPD [kPa]

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
