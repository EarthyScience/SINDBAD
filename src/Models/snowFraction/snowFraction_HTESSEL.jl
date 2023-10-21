export snowFraction_HTESSEL

#! format: off
@bounds @describe @units @with_kw struct snowFraction_HTESSEL{T1} <: snowFraction
    snow_cover_param::T1 = 15.0 | (1.0, 100.0) | "Snow Cover Parameter" | "mm"
end
#! format: on

function compute(params::snowFraction_HTESSEL, forcing, land, helpers)
    ## unpack parameters
    @unpack_snowFraction_HTESSEL params

    ## unpack land variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.pools
        o_one ∈ land.constants
    end

    ## calculate variables
    # suggested by Sujan [after HTESSEL GHM]

    frac_snow = min(o_one, sum(snowW) / snow_cover_param)

    ## pack land variables
    @pack_land frac_snow → land.states
    return land
end

@doc """
computes the snow pack & fraction of snow cover following the HTESSEL approach

# Parameters
$(SindbadParameters)

---

# compute:
Calculate snow cover fraction using snowFraction_HTESSEL

*Inputs*
 - land.fluxes.snow: snowfall

*Outputs*
 - land.fluxes.evaporation: soil evaporation flux
 - land.pools.snowW: adds snow fall to the snow pack
 - land.states.frac_snow: updates snow cover fraction

---

# Extended help

*References*
 - H-TESSEL = land surface scheme of the European Centre for Medium-  Range Weather Forecasts" operational weather forecast system  Balsamo et al.; 2009

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung
"""
snowFraction_HTESSEL
