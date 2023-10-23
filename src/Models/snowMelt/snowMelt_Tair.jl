export snowMelt_Tair

#! format: off
@bounds @describe @units @with_kw struct snowMelt_Tair{T1} <: snowMelt
    rate::T1 = 1.0 | (0.1, 10.0) | "snow melt rate" | "mm/°C"
end
#! format: on

function compute(params::snowMelt_Tair, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_snowMelt_Tair params
    @unpack_nt f_airT ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        (WBP, frac_snow) ⇐ land.states
        snowW ⇐ land.pools
        ΔsnowW ⇐ land.pools
        z_zero ⇐ land.constants
        n_snowW ⇐ land.constants
    end
    # effect of temperature on snow melt = snowMeltRate * f_airT
    pRate = (rate * helpers.dates.timesteps_in_day)
    Tterm = maxZero(pRate * f_airT)

    # snow melt [mm/day] is calculated as a simple function of temperature & scaled with the snow covered fraction
    snow_melt = min(totalS(snowW, ΔsnowW), Tterm * frac_snow)

    # divide snowmelt loss equally from all layers
    ΔsnowW .= ΔsnowW .- snow_melt / n_snowW

    # a Water Balance Pool variable that tracks how much water is still "available"
    WBP = WBP + snow_melt

    ## pack land variables
    @pack_nt begin
        snow_melt ⇒ land.fluxes
        Tterm ⇒ land.fluxes
        WBP ⇒ land.states
        ΔsnowW ⇒ land.pools
    end
    return land
end

function update(params::snowMelt_Tair, forcing, land, helpers)
    @unpack_snowMelt_Tair params

    ## unpack variables
    @unpack_nt begin
        snowW ⇐ land.pools
        ΔsnowW ⇐ land.pools
    end

    # update snow pack
    snowW .= snowW .+ ΔsnowW

    # reset delta storage	
    ΔsnowW .= ΔsnowW .- ΔsnowW

    ## pack land variables
    @pack_nt begin
        snowW ⇒ land.pools
        ΔsnowW ⇒ land.pools
    end
    return land
end

@doc """
computes the snow melt term as function of air temperature

# Parameters
$(SindbadParameters)

---

# compute:
Calculate snowmelt and update s.w.wsnow using snowMelt_Tair

*Inputs*
 - forcing.f_airT: temperature [C]
 - helpers.dates.timesteps_in_day: model time steps per day
 - land.fluxes.Tterm: effect of temperature on snow melt [mm/time]
 - land.states.frac_snow: snow cover fraction [-]

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
