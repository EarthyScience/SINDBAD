export vegAvailableWater_sigmoid

#! format: off
@bounds @describe @units @with_kw struct vegAvailableWater_sigmoid{T1} <: vegAvailableWater
    exp_factor::T1 = 1.0 | (0.02, 3.0) | "multiplier of B factor of exponential rate" | ""
end
#! format: on

function define(params::vegAvailableWater_sigmoid, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegAvailableWater_sigmoid params

    ## unpack land variables
    @unpack_nt begin
        soilW ⇐ land.pools
    end

    θ_dos = zero(soilW)
    θ_fc_dos = zero(soilW)
    PAW = zero(soilW)
    soilWStress = zero(soilW)
    maxWater = zero(soilW)

    ## pack land variables
    @pack_nt (θ_dos, θ_fc_dos, PAW, soilWStress, maxWater) ⇒ land.states
    return land
end

function compute(params::vegAvailableWater_sigmoid, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegAvailableWater_sigmoid params

    ## unpack land variables
    @unpack_nt begin
        (wWP, wFC, wSat, soil_β) ⇐ land.properties
        root_water_efficiency ⇐ land.diagnostics
        soilW ⇐ land.pools
        ΔsoilW ⇐ land.pools
        (θ_dos, θ_fc_dos, PAW, soilWStress, maxWater) ⇐ land.states
        (z_zero, o_one) ⇐ land.constants
    end
    for sl ∈ eachindex(soilW)
        θ_dos = (soilW[sl] + ΔsoilW[sl]) / wSat[sl]
        θ_fc_dos = wFC[sl] / wSat[sl]
        tmpSoilWStress = clampZeroOne(o_one / (o_one + exp(-exp_factor * soil_β[sl] * (θ_dos - θ_fc_dos))))
        @rep_elem tmpSoilWStress ⇒ (soilWStress, sl, :soilW)
        maxWater = clampZeroOne(soilW[sl] + ΔsoilW[sl] - wWP[sl])
        PAW_sl = root_water_efficiency[sl] * maxWater * tmpSoilWStress
        @rep_elem PAW_sl ⇒ (PAW, sl, :soilW)
    end

    ## pack land variables
    @pack_nt (PAW, soilWStress) ⇒ land.states
    return land
end

@doc """
calculate the actual amount of water that is available for plants

# Parameters
$(SindbadParameters)

---

# compute:
Plant available water using vegAvailableWater_sigmoid

*Inputs*
 - land.pools.soilW

*Outputs*
 - land.states.root_water_efficiency as nZix for soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
vegAvailableWater_sigmoid
