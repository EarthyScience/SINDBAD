export runoffSaturationExcess_Bergstroem1992

#! format: off
@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992{T1} <: runoffSaturationExcess
    β::T1 = 1.1 | (0.1, 5.0) | "berg exponential parameter" | ""
end
#! format: on

function compute(params::runoffSaturationExcess_Bergstroem1992, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffSaturationExcess_Bergstroem1992 params

    ## unpack land variables
    @unpack_land begin
        WBP ∈ land.states
        wSat ∈ land.properties
        soilW ∈ land.pools
        ΔsoilW ∈ land.pools
    end
    # @show WBP
    tmp_smax_veg = sum(wSat)
    tmp_soilW_total = sum(soilW)
    # calculate land runoff from incoming water & current soil moisture
    tmp_sat_exc_frac = clampZeroOne((tmp_soilW_total / tmp_smax_veg)^β)

    sat_excess_runoff = WBP * tmp_sat_exc_frac

    # update water balance pool
    WBP = WBP - sat_excess_runoff

    ## pack land variables
    @pack_land begin
        sat_excess_runoff → land.fluxes
        WBP → land.states
    end
    return land
end

@doc """
saturation excess runoff using original Bergström method

# Parameters
$(SindbadParameters)

---

# compute:
Saturation runoff using runoffSaturationExcess_Bergstroem1992

*Inputs*
 - land.states. : vegetation fraction
 - smax1 : maximum water capacity of first soil layer [mm]
 - smax2 : maximum water capacity of second soil layer [mm]

*Outputs*
 - land.fluxes.sat_excess_runoff : runoff from land [mm/time]
 - land.runoffSaturationExcess.p_berg : scaled berg parameter
 - land.states.WBP : water balance pool [mm]

---

# Extended help

*References*
 - Bergström, S. (1992). The HBV model–its structure & applications. SMHI.

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
 - 1.1 on 27.11.2019 [skoirala]: changed to handle any number of soil layers
 - 1.2 on 10.02.2020 [ttraut]: modyfying variable name to match the new SINDBAD version

*Created by:*
 - ttraut
"""
runoffSaturationExcess_Bergstroem1992
