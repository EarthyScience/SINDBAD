export WUE_VPDDayCo2

#! format: off
@bounds @describe @units @with_kw struct WUE_VPDDayCo2{T1,T2,T3,T4} <: WUE
    WUE_one_hpa::T1 = 9.2 | (4.0, 17.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
    base_ambient_CO2::T2 = 380.0 | (300.0, 500.0) | "" | "ppm"
    sat_ambient_CO2::T3 = 500.0 | (100.0, 2000.0) | "" | "ppm"
    kpa_to_hpa::T4 = 10.0 | (-Inf, Inf) | "unit conversion kPa to hPa" | ""
end
#! format: on

function compute(params::WUE_VPDDayCo2, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_WUE_VPDDayCo2 params
    @unpack_forcing f_VPD_day ∈ forcing

    ## unpack land variables
    @unpack_land begin
        ambient_CO2 ∈ land.states
        tolerance ∈ helpers.numbers
        (z_zero, o_one) ∈ land.constants
    end

    ## calculate variables
    # "WUEat1hPa"
    WUENoCO2 = WUE_one_hpa * o_one / sqrt(kpa_to_hpa * (f_VPD_day + tolerance))
    fCO2_CO2 = o_one + (ambient_CO2 - base_ambient_CO2) / (ambient_CO2 - base_ambient_CO2 + sat_ambient_CO2)
    WUE = WUENoCO2 * fCO2_CO2

    ## pack land variables
    @pack_land WUENoCO2 → land.WUE
    @pack_land WUE → land.diagnostics
    return land
end

@doc """
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# Parameters
$(SindbadParameters)

---

# compute:
Estimate wue using WUE_VPDDayCo2

*Inputs*
 - WUEat1hPa: the VPD at 1 hpa
 - forcing.f_VPD_day: daytime mean VPD [kPa]

*Outputs*
 - land.WUE.WUENoCO2: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O] without co2 effect

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUEat1hPa  across fluxNet sites
 - skoirala
"""
WUE_VPDDayCo2
