export gppAirT_Wang2014

@bounds @describe @units @with_kw struct gppAirT_Wang2014{T1} <: gppAirT
	Tmax::T1 = 10.0 | (5.0, 35.0) | "?? Check with martin" | "°C"
end

function compute(o::gppAirT_Wang2014, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_Wang2014 o
    @unpack_forcing TairDay ∈ forcing
    @unpack_land (zero, one) ∈ helpers.numbers

    ## calculate variables
    pTmax = Tmax
    tsc = TairDay / pTmax
    TempScGPP = clamp(tsc, zero, one)

    ## pack land variables
    @pack_land TempScGPP => land.gppAirT
    return land
end

@doc """
calculate the temperature stress on gppPot based on Wang2014

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of temperature using gppAirT_Wang2014

*Inputs*
 - forcing.TairDay: daytime temperature [°C]

*Outputs*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP
 -

---

# Extended help

*References*
 - Wang, H., Prentice, I. C., & Davis, T. W. (2014). Biophsyical constraints on gross  primary production by the terrestrial biosphere. Biogeosciences, 11[20], 5987.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppAirT_Wang2014