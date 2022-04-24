export gppAirT_MOD17

@bounds @describe @units @with_kw struct gppAirT_MOD17{T1, T2} <: gppAirT
	Tmax::T1 = 20.0 | (10.0, 35.0) | "temperature for max GPP" | "°C"
	Tmin::T2 = 5.0 | (0.0, 15.0) | "temperature for min GPP" | "°C"
end

function compute(o::gppAirT_MOD17, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_MOD17 o
    @unpack_forcing TairDay ∈ forcing
    @unpack_land (zero, one) ∈ helpers.numbers


    ## calculate variables
    tsc = TairDay / ((one - Tmin) * (Tmax - Tmin)) #@needscheck: if the equation reflects the original implementation
    TempScGPP = clamp(tsc, zero, one)

    ## pack land variables
    @pack_land TempScGPP => land.gppAirT
    return land
end

@doc """
calculate the temperature stress on gppPot based on GPP - MOD17 model

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of temperature using gppAirT_MOD17

*Inputs*
 - forcing.TairDay: daytime temperature [°C]

*Outputs*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP
 -

---

# Extended help

*References*
 - MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
 - Running; S. W.; Nemani; R. R.; Heinsch; F. A.; Zhao; M.; Reeves; M.  & Hashimoto, H. (2004). A continuous satellite-derived measure of global terrestrial  primary production. Bioscience, 54[6], 547-560.
 - Zhao, M., Heinsch, F. A., Nemani, R. R., & Running, S. W. (2005). Improvements  of the MODIS terrestrial gross & net primary production global data set. Remote  sensing of Environment, 95[2], 164-176.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gppAirT_MOD17