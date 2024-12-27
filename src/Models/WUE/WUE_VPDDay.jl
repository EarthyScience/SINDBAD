export WUE_VPDDay

#! format: off
@bounds @describe @units @timescale @with_kw struct WUE_VPDDay{T1,T2} <: WUE
    WUE_one_hpa::T1 = 9.2 | (4.0, 17.0) | "WUE at 1 hpa VPD" | "gC/mmH2O" | ""
    kpa_to_hpa::T2 = 10.0 | (-Inf, Inf) | "unit conversion kPa to hPa" | "" | ""
end
#! format: on

function compute(params::WUE_VPDDay, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_WUE_VPDDay params
    @unpack_nt f_VPD_day ⇐ forcing
    @unpack_nt begin
        tolerance ⇐ helpers.numbers
        (z_zero, o_one) ⇐ land.constants
    end
    ## calculate variables
    # "WUEat1hPa" | ""
    WUE = WUE_one_hpa * o_one / sqrt(kpa_to_hpa * (f_VPD_day + tolerance))

    ## pack land variables
    @pack_nt WUE ⇒ land.diagnostics
    return land
end

@doc """
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# Parameters
$(SindbadParameters)

---

# compute:
Estimate wue using WUE_VPDDay

*Inputs*
 - WUEat1hPa: the VPD at 1 hpa
 - forcing.f_VPD_day: daytime mean VPD [kPa]

*Outputs*
 - land.diagnostics.WUE: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O]

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUEat1hPa  across fluxNet sites
 - skoirala
"""
WUE_VPDDay
