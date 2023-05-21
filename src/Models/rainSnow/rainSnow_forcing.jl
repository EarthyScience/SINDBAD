export rainSnow_forcing

@bounds @describe @units @with_kw struct rainSnow_forcing{T1} <: rainSnow
	SF_scale::T1 = 1.0 | (0.0, 3.0) | "scaling factor for snow fall" | ""
end

function compute(o::rainSnow_forcing, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_rainSnow_forcing o
    @unpack_forcing (Rain, Snow) ∈ forcing

    ## unpack land variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
    end

    ## calculate variables
    rain = Rain
    snow = Snow * (SF_scale)
    precip = rain + snow

    # add snowfall to snowpack of the first layer
    ΔsnowW[1] = ΔsnowW[1] + snow

	## pack land variables
    @pack_land begin
        (precip, rain, snow) => land.rainSnow
        ΔsnowW => land.states
    end
    return land
end

function update(o::rainSnow_forcing, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
    end
    # update snow pack
    snowW[1] = snowW[1] + ΔsnowW[1]

    # reset delta storage	
    ΔsnowW[1] = ΔsnowW[1] - ΔsnowW[1]

    ## pack land variables
    @pack_land begin
        snowW => land.pools
        ΔsnowW => land.states
    end
    return land
end

@doc """
stores the time series of rainfall and snowfall from forcing & scale snowfall if SF_scale parameter is optimized

# Parameters
$(PARAMFIELDS)

---

# compute:
Set rain and snow to fe.rainsnow. using rainSnow_forcing

*Inputs*
 - forcing.Rain
 - forcing.Snow
 - info

*Outputs*
 - land.rainSnow.rain: liquid rainfall from forcing input
 - land.rainSnow.snow: snowfall estimated as the rain when tair <  threshold

# update

update pools and states in rainSnow_forcing

 - forcing.Snow using the snowfall scaling parameter which can be optimized

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainSnow_forcing