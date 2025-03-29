export rainSnow_Tair

#! format: off
@bounds @describe @units @timescale @with_kw struct rainSnow_Tair{T1} <: rainSnow
    airT_thres::T1 = 0.0 | (-5.0, 5.0) | "threshold for separating rain and snow" | "°C" | ""
end
#! format: on

function compute(params::rainSnow_Tair, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_rainSnow_Tair params
    @unpack_nt (f_rain, f_airT) ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        snowW ⇐ land.pools
        ΔsnowW ⇐ land.pools
    end
    rain = f_rain
    snow = zero(f_rain)
    ## calculate variables
    if f_airT < airT_thres
        snow = f_rain
        rain = zero(f_rain)
    end
    precip = rain + snow

    # add snowfall to snowpack of the first layer
    @add_to_elem snow ⇒ (ΔsnowW, 1, :snowW)
    ## pack land variables
    @pack_nt begin
        (precip, rain, snow) ⇒ land.fluxes
        ΔsnowW ⇒ land.pools
    end
    return land
end

function update(params::rainSnow_Tair, forcing, land, helpers)
    @unpack_rainSnow_Tair params

    ## unpack variables
    @unpack_nt begin
        snowW ⇐ land.pools
        ΔsnowW ⇐ land.pools
    end

    ## update variables
    # update snow pack
    snowW[1] = snowW[1] + ΔsnowW[1]

    # reset delta storage	
    ΔsnowW[1] = ΔsnowW[1] - ΔsnowW[1]

    ## pack land variables
    @pack_nt begin
        snowW ⇒ land.pools
        # ΔsnowW ⇒ land.pools
    end
    return land
end

purpose(::Type{rainSnow_Tair}) = "separates the rain & snow based on temperature threshold"

@doc """

$(getBaseDocString(rainSnow_Tair))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainSnow_Tair
