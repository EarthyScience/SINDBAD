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
        (p_wWP, p_wFC, p_wSat, p_β) ∈ land.soilWBase
        p_frac_root_to_soil_depth ∈ land.rootFraction
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        (𝟘, 𝟙) ∈ helpers.numbers
        (θ_dos, θ_fc_dos, PAW, soilWStress, maxWater) ∈ land.vegAvailableWater
    end
    for sl ∈ eachindex(soilW)
        θ_dos = (soilW[sl] + ΔsoilW[sl]) / p_wSat[sl]
        θ_fc_dos = p_wFC[sl] / p_wSat[sl]
        tmpSoilWStress = clamp_01(𝟙 / (𝟙 + exp(-exp_factor * p_β[sl] * (θ_dos - θ_fc_dos))))
        @rep_elem tmpSoilWStress => (soilWStress, sl, :soilW)
        maxWater = clamp_01(soilW[sl] + ΔsoilW[sl] - p_wWP[sl])
        PAW_sl = p_frac_root_to_soil_depth[sl] * maxWater * tmpSoilWStress
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
 - land.rootFraction.p_frac_root_to_soil_depth as nPix;nZix for soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
vegAvailableWater_sigmoid
