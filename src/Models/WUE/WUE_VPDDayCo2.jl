export WUE_VPDDayCo2

#! format: off
@bounds @describe @units @timescale @with_kw struct WUE_VPDDayCo2{T1,T2,T3,T4} <: WUE
    WUE_one_hpa::T1 = 9.2 | (4.0, 17.0) | "WUE at 1 hpa VPD" | "gC/mmH2O" | ""
    base_ambient_CO2::T2 = 380.0 | (300.0, 500.0) | "" | "ppm" | ""
    sat_ambient_CO2::T3 = 500.0 | (100.0, 2000.0) | "" | "ppm" | ""
    kpa_to_hpa::T4 = 10.0 | (-Inf, Inf) | "unit conversion kPa to hPa" | "" | ""
end
#! format: on

function compute(params::WUE_VPDDayCo2, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_WUE_VPDDayCo2 params
    @unpack_nt f_VPD_day ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        ambient_CO2 ⇐ land.states
        tolerance ⇐ helpers.numbers
        (z_zero, o_one) ⇐ land.constants
    end

    ## calculate variables
    # "WUEat1hPa" | ""
    WUENoCO2 = WUE_one_hpa * o_one / sqrt(kpa_to_hpa * (f_VPD_day + tolerance))
    fCO2_CO2 = o_one + (ambient_CO2 - base_ambient_CO2) / (ambient_CO2 - base_ambient_CO2 + sat_ambient_CO2)
    WUE = WUENoCO2 * fCO2_CO2

    ## pack land variables
    @pack_nt WUENoCO2 ⇒ land.diagnostics
    @pack_nt WUE ⇒ land.diagnostics
    return land
end

purpose(::Type{WUE_VPDDayCo2}) = "calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD"

@doc """

$(getModelDocString(WUE_VPDDayCo2))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]

*Created by*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUEat1hPa  across fluxNet sites
 - skoirala | @dr-ko
"""
WUE_VPDDayCo2
