export rainSnow_Tair

@bounds @describe @units @with_kw struct rainSnow_Tair{T1} <: rainSnow
	Tair_thres::T1 = 0.0 | (-5.0, 5.0) | "threshold for separating rain and snow" | "°C"
end

function precompute(o::rainSnow_Tair, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters and forcing
    precip = 0f0 #helpers.numbers.𝟘
    rain = precip
    snow = precip
    @pack_land (precip, rain, snow) => land.rainSnow
    return land
end

function compute(o::rainSnow_Tair, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters and forcing
    @unpack_rainSnow_Tair o
    @unpack_forcing (Rain, Tair) ∈ forcing

    ## unpack land variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
        𝟘 ∈ helpers.numbers
        (precip, rain, snow) ∈ land.rainSnow
    end
    ## calculate variables
    if Tair < Tair_thres
        snow = Rain
        rain = 0f0 #𝟘
    else
        rain = Rain
        snow = 0f0 #𝟘
    end
    precip = rain + snow

	# add snowfall to snowpack of the first layer
    ΔsnowW[1] = ΔsnowW[1] + snow
    ## pack land variables
    @pack_land (precip, rain, snow) => land.rainSnow
        # ΔsnowW => land.states
    return land
end

function update(o::rainSnow_Tair, forcing, land::NamedTuple, helpers::NamedTuple)
    @unpack_rainSnow_Tair o

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
$(PARAMFIELDS)

---

# compute:
Set rain and snow to fe.rainsnow. using rainSnow_Tair

*Inputs*
 - forcing.Rain
 - forcing.Tair

*Outputs*
 - land.rainSnow.rain: liquid rainfall from forcing input
 - land.rainSnow.snow: snowfall estimated as the rain when tair <  threshold

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