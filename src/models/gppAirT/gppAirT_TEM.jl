export gppAirT_TEM

@bounds @describe @units @with_kw struct gppAirT_TEM{T1, T2, T3} <: gppAirT
	Tmin::T1 = 5.0 | (0.0, 15.0) | "?? Check with martin" | "°C"
	Tmax::T2 = 20.0 | (10.0, 35.0) | "?? Check with martin" | "°C"
	Topt::T3 = 15.0 | (5.0, 30.0) | "?? Check with martin" | "°C"
end

function compute(o::gppAirT_TEM, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_gppAirT_TEM o
	@unpack_forcing TairDay ∈ forcing


	## calculate variables
	tmp = 1.0
	pTmin = TairDay - (Tmin * tmp)
	pTmax = TairDay - (Tmax * tmp)
	pTopt = Topt * tmp
	pTScGPP = pTmin * pTmax / ((pTmin * pTmax) - (TairDay - pTopt) ^ 2)
	TempScGPP[TairDay > Tmax] = 0
	TempScGPP[TairDay < Tmin] = 0
	TempScGPP = min(max(pTScGPP, infotem.helpers.zero), 1)

	## pack land variables
	@pack_land TempScGPP => land.gppAirT
	return land
end

@doc """
calculate the temperature stress for gppPot based on TEM

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of temperature using gppAirT_TEM

*Inputs*
 - forcing.TairDay: daytime temperature [°C]

*Outputs*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gppAirT_TEM