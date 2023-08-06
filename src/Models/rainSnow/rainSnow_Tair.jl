export rainSnow_Tair

#! format: off
@bounds @describe @units @with_kw struct rainSnow_Tair{T1} <: rainSnow
    Tair_thres::T1 = 0.0 | (-5.0, 5.0) | "threshold for separating rain and snow" | "°C"
end
#! format: on

function compute(p_struct::rainSnow_Tair, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_rainSnow_Tair p_struct
    @unpack_forcing (Rain, Tair) ∈ forcing

    ## unpack land variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
    end
    rain = Rain
    snow = z_zero
    ## calculate variables
    if Tair < Tair_thres
        snow = Rain
        rain = z_zero
    end
    precip = rain + snow

    # add snowfall to snowpack of the first layer
    @add_to_elem snow => (ΔsnowW, 1, :snowW)
    ## pack land variables
    @pack_land begin
        (precip, rain, snow) => land.fluxes
        ΔsnowW => land.states
    end
    return land
end

function update(p_struct::rainSnow_Tair, forcing, land, helpers)
    @unpack_rainSnow_Tair p_struct

    ## unpack variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
    end

    ## update variables
    # update snow pack
    snowW[1] = snowW[1] + ΔsnowW[1]

    # reset delta storage	
    ΔsnowW[1] = ΔsnowW[1] - ΔsnowW[1]

    ## pack land variables
    @pack_land begin
        snowW => land.pools
        # ΔsnowW => land.states
    end
    return land
end

@doc """
separates the rain & snow based on temperature threshold

# Parameters
$(SindbadParameters)

---

# compute:
Set rain and snow to fe.rainsnow. using rainSnow_Tair

*Inputs*
 - forcing.Rain
 - forcing.Tair

*Outputs*
 - land.fluxes.rain: liquid rainfall from forcing input
 - land.fluxes.snow: snowfall estimated as the rain when tair <  threshold

# update

update pools and states in rainSnow_Tair


---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainSnow_Tair
