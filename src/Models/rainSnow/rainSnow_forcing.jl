export rainSnow_forcing

#! format: off
@bounds @describe @units @with_kw struct rainSnow_forcing{T1} <: rainSnow
    snowfall_scalar::T1 = 1.0 | (0.0, 3.0) | "scaling factor for snow fall" | ""
end
#! format: on

function compute(params::rainSnow_forcing, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_rainSnow_forcing params
    @unpack_forcing (f_rain, f_snow) ∈ forcing

    ## unpack land variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.pools
    end

    ## calculate variables
    rain = f_rain
    snow = f_snow * snowfall_scalar
    precip = rain + snow

    # add snowfall to snowpack of the first layer
    ΔsnowW[1] = ΔsnowW[1] + snow

    ## pack land variables
    @pack_land begin
        (precip, rain, snow) → land.fluxes
        ΔsnowW → land.pools
    end
    return land
end

function update(params::rainSnow_forcing, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.pools
    end
    # update snow pack
    snowW[1] = snowW[1] + ΔsnowW[1]

    # reset delta storage	
    ΔsnowW[1] = ΔsnowW[1] - ΔsnowW[1]

    ## pack land variables
    @pack_land begin
        snowW → land.pools
        ΔsnowW → land.pools
    end
    return land
end

@doc """
stores the time series of rainfall and snowfall from forcing & scale snowfall if snowfall_scalar parameter is optimized

# Parameters
$(SindbadParameters)

---

# compute:
Set rain and snow to fe.rainsnow. using rainSnow_forcing

*Inputs*
 - forcing.f_rain
 - forcing.Snow
 - info

*Outputs*
 - land.fluxes.rain: liquid rainfall from forcing input
 - land.fluxes.snow: snowfall estimated as the rain when airT <  threshold

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
