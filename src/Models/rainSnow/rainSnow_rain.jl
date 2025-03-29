export rainSnow_rain

struct rainSnow_rain <: rainSnow end

function define(params::rainSnow_rain, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_nt f_rain ⇐ forcing

    ## calculate variables
    snow = zero(f_rain)
    rain = f_rain
    precip = rain

    ## pack land variables
    @pack_nt begin
        (precip, rain, snow) ⇒ land.fluxes
    end
    return land
end

function compute(params::rainSnow_rain, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_nt f_rain ⇐ forcing

    ## calculate variables
    rain = f_rain
    precip = rain

    ## pack land variables
    @pack_nt begin
        (precip, rain) ⇒ land.fluxes
    end
    return land
end

purpose(::Type{rainSnow_rain}) = "set all precip to rain"

@doc """

$(getBaseDocString())

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainSnow_rain
