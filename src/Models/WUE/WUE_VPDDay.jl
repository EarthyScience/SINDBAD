export WUE_VPDDay

#! format: off
@bounds @describe @units @with_kw struct WUE_VPDDay{T1,T2,T3} <: WUE
    WUEatOnehPa::T1 = 9.2 | (4.0, 17.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
    kpa_to_hpa::T3 = 10.0 | (nothing, nothing) | "unit conversion kPa to hPa" | ""
end
#! format: on

function compute(p_struct::WUE_VPDDay, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_WUE_VPDDay p_struct
    @unpack_forcing VPDDay ∈ forcing
    @unpack_land begin
        tolerance ∈ helpers.numbers
        (z_zero, o_one) ∈ land.wCycleBase
    end
    ## calculate variables
    # "WUEat1hPa"
    WUE = WUEatOnehPa * o_one / sqrt(kpa_to_hpa * (VPDDay + tolerance))

    ## pack land variables
    @pack_land WUE => land.WUE
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
 - forcing.VPDDay: daytime mean VPD [kPa]

*Outputs*
 - land.WUE.WUE: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O]

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
