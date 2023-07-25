export vegAvailableWater_sigmoid

#! format: off
@bounds @describe @units @with_kw struct vegAvailableWater_sigmoid{T1} <: vegAvailableWater
    exp_factor::T1 = 1.0 | (0.02, 3.0) | "multiplier of B factor of exponential rate" | ""
end
#! format: on

function define(p_struct::vegAvailableWater_sigmoid, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegAvailableWater_sigmoid p_struct

    ## unpack land variables
    @unpack_land begin
        soilW ∈ land.pools
    end

    θ_dos = zero(soilW)
    θ_fc_dos = zero(soilW)
    PAW = zero(soilW)
    soilWStress = zero(soilW)
    maxWater = zero(soilW)

    ## pack land variables
    @pack_land (θ_dos, θ_fc_dos, PAW, soilWStress, maxWater) => land.vegAvailableWater
    return land
end

function compute(p_struct::vegAvailableWater_sigmoid, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegAvailableWater_sigmoid p_struct

    ## unpack land variables
    @unpack_land begin
        (WP, wFC, wSat, soil_β) ∈ land.soilWBase
        root_water_efficiency ∈ land.rootWaterEfficiency
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        (θ_dos, θ_fc_dos, PAW, soilWStress, maxWater) ∈ land.vegAvailableWater
        (z_zero, o_one) ∈ land.wCycleBase
    end
    for sl ∈ eachindex(soilW)
        θ_dos = (soilW[sl] + ΔsoilW[sl]) / wSat[sl]
        θ_fc_dos = wFC[sl] / wSat[sl]
        tmpSoilWStress = clamp_01(o_one / (o_one + exp(-exp_factor * soil_β[sl] * (θ_dos - θ_fc_dos))))
        @rep_elem tmpSoilWStress => (soilWStress, sl, :soilW)
        maxWater = clamp_01(soilW[sl] + ΔsoilW[sl] - WP[sl])
        PAW_sl = root_water_efficiency[sl] * maxWater * tmpSoilWStress
        @rep_elem PAW_sl => (PAW, sl, :soilW)
    end

    ## pack land variables
    @pack_land (PAW, soilWStress) => land.vegAvailableWater
    return land
end

@doc """
calculate the actual amount of water that is available for plants

# Parameters
$(PARAMFIELDS)

---

# compute:
Plant available water using vegAvailableWater_sigmoid

*Inputs*
 - land.pools.soilW

*Outputs*
 - land.rootWaterEfficiency.root_water_efficiency as nPix;nZix for soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
vegAvailableWater_sigmoid
