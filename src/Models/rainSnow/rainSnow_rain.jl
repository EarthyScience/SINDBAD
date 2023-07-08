export rainSnow_rain

struct rainSnow_rain <: rainSnow end

function define(o::rainSnow_rain, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_forcing Rain ∈ forcing

    ## calculate variables
    snow = helpers.numbers.𝟘
    rain = Rain
    precip = rain

    ## pack land variables
    @pack_land begin
        (precip, rain, snow) => land.rainSnow
    end
    return land
end

function compute(o::rainSnow_rain, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_forcing Rain ∈ forcing

    ## calculate variables
    rain = Rain
    snow = zero(rain)
    precip = rain

    ## pack land variables
    @pack_land begin
        (precip, rain, snow) => land.rainSnow
    end
    return land
end

@doc """
set all precip to rain

# Parameters
$(PARAMFIELDS)

---

# compute:
Set all precip to rain

*Inputs*
 - forcing.Rain

*Outputs*
 - land.rainSnow.rain: liquid rainfall from forcing input
 - land.rainSnow.snow: 0

# update

update pools and states in rainSnow_rain


---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainSnow_rain
