export snowMelt_Tair

@bounds @describe @units @with_kw struct snowMelt_Tair{T1} <: snowMelt
	rate::T1 = 1.0 | (0.1, 10.0) | "snow melt rate" | "mm/°C"
end

function compute(o::snowMelt_Tair, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_snowMelt_Tair o
    @unpack_forcing Tair ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (WBP, snowFraction) ∈ land.states
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
		zero ∈ helpers.numbers
    end
    # effect of temperature on snow melt = snowMeltRate * Tair
    pRate = (rate * helpers.dates.nStepsDay)
    Tterm = max(pRate * Tair, zero)

    # snow melt [mm/day] is calculated as a simple function of temperature & scaled with the snow covered fraction
    snowMelt = min(sum(snowW + ΔsnowW), Tterm * snowFraction)

	# divide snowmelt loss equally from all layers
    ΔsnowW = ΔsnowW .- snowMelt / length(snowW)

    # a Water Balance Pool variable that tracks how much water is still "available"
    WBP = WBP + snowMelt

    ## pack land variables
    @pack_land begin
        snowMelt => land.fluxes
        Tterm => land.snowMelt
        WBP => land.states
        ΔsnowW => land.states
    end
    return land
end

function update(o::snowMelt_Tair, forcing, land, helpers)
    @unpack_snowMelt_Tair o

    ## unpack variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
    end

    # update snow pack
    snowW = snowW + ΔsnowW

    # reset delta storage	
    ΔsnowW = ΔsnowW - ΔsnowW

    ## pack land variables
    @pack_land begin
        snowW => land.pools
        ΔsnowW => land.states
    end
    return land
end

@doc """
computes the snow melt term as function of air temperature

# Parameters
$(PARAMFIELDS)

---

# compute:
Calculate snowmelt and update s.w.wsnow using snowMelt_Tair

*Inputs*
 - forcing.Tair: temperature [C]
 - helpers.dates.nStepsDay: model time steps per day
 - land.snowMelt.Tterm: effect of temperature on snow melt [mm/time]
 - land.states.snowFraction: snow cover fraction [-]

*Outputs*
 - land.fluxes.snowMelt: snow melt [mm/time]

# update

update pools and states in snowMelt_Tair

 -
 - land.pools.snowW: water storage [mm]
 - land.states.WBP: water balance pool [mm]

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung

*Notes*
 - may not be working well for longer time scales (like for weekly |  longer time scales). Warnings needs to be set accordingly.
 - may not be working well for longer time scales (like for weekly |  longer time scales). Warnings needs to be set accordingly.  
"""
snowMelt_Tair