export gppAirT_CASA

@bounds @describe @units @with_kw struct gppAirT_CASA{T1, T2, T3} <: gppAirT
	Topt::T1 = 25.0 | (5.0, 35.0) | "check in CASA code" | "°C"
	ToptA::T2 = 0.2 | (0.1, 0.3) | "increasing slope of sensitivity" | ""
	ToptB::T3 = 0.3 | (0.15, 0.5) | "decreasing slope of sensitivity" | ""
end

function compute(o::gppAirT_CASA, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_gppAirT_CASA o
	@unpack_forcing TairDay ∈ forcing


	## calculate variables
	# get air temperature during the day
	AIRT = TairDay
	# make it varying in space
	tmp = 1.0
	TOPT = Topt * tmp
	A = ToptA * tmp
	B = ToptB * tmp
	# CALCULATE T1: account for effects of temperature stress
	# reflects the empirical observation that plants in very
	# cold habitats typically have low maximum rates
	# T1 = 0.8 + 0.02 * TOPT - 0.0005 * TOPT ^ 2
	# this would make sense if TOPT would be the same everywhere.
	T1 = 1
	# first half of the response curve
	T2p1 = 1 / (1 + exp(A * (-10.0))) / (1 + exp(A * (- 10.0)))
	T2C1 = 1 / T2p1
	T21 = T2C1 / (1 + exp(A * (TOPT - 10 - AIRT))) / (1 + exp(A * (- TOPT - 10 + AIRT)))
	# second half of the response curve
	T2p2 = 1 / (1 + exp(B * (-10.0))) / (1 + exp(B * (- 10.0)))
	T2C2 = 1 / T2p2
	T22 = T2C2 / (1 + exp(B * (TOPT - 10 - AIRT))) / (1 + exp(B * (- TOPT - 10 + AIRT)))
	# combine the response curves
	v = AIRT >= TOPT
	T2 = T21
	T2[v] = T22[v]
	# assign it to the array
	TempScGPP = T2 * T1

	## pack land variables
	@pack_land TempScGPP => land.gppAirT
	return land
end

@doc """
calculate the temperature stress for gppPot based on CASA & Potter

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of temperature using gppAirT_CASA

*Inputs*
 - forcing.TairDay: daytime temperature [°C]

*Outputs*
 - land.gppDirRadiation.LightScGPP: effect of light saturation on potential GPP
 -

---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gppAirT_CASA