export snowFraction_HTESSEL

#! format: off
@bounds @describe @units @timescale @with_kw struct snowFraction_HTESSEL{T1} <: snowFraction
    snow_cover_param::T1 = 15.0 | (1.0, 100.0) | "Snow Cover Parameter" | "mm" | ""
end
#! format: on

function compute(params::snowFraction_HTESSEL, forcing, land, helpers)
    ## unpack parameters
    @unpack_snowFraction_HTESSEL params

    ## unpack land variables
    @unpack_nt begin
        snowW ⇐ land.pools
        ΔsnowW ⇐ land.pools
        o_one ⇐ land.constants
    end

    ## calculate variables
    # suggested by Sujan [after HTESSEL GHM]

    frac_snow = min(o_one, sum(snowW) / snow_cover_param)

    ## pack land variables
    @pack_nt frac_snow ⇒ land.states
    return land
end

purpose(::Type{snowFraction_HTESSEL}) = "computes the snow pack & fraction of snow cover following the HTESSEL approach"

@doc """

$(getModelDocString(snowFraction_HTESSEL))

---

# Extended help

*References*
 - H-TESSEL = land surface scheme of the European Centre for Medium-  Range Weather Forecasts" operational weather forecast system  Balsamo et al.; 2009

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by*
 - mjung
"""
snowFraction_HTESSEL
