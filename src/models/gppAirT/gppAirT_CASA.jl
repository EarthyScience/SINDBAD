export gppAirT_CASA

@bounds @describe @units @with_kw struct gppAirT_CASA{T1, T, T3, T4} <: gppAirT
	Topt::T1 = 25.0 | (5.0, 35.0) | "check in CASA code" | "°C"
	ToptA::T = 0.2 | (0.1, 0.3) | "increasing slope of sensitivity" | ""
	ToptB::T3 = 0.3 | (0.15, 0.5) | "decreasing slope of sensitivity" | ""
	Texp::T4 = 10 | (9, 11) | "reference for exponent of sensitivity" | ""
end

function compute(o::gppAirT_CASA, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_CASA o
    @unpack_forcing TairDay ∈ forcing
    @unpack_land begin
        𝟙 ∈ helpers.numbers
    end


    ## calculate variables
    # CALCULATE T1: account for effects of temperature stress reflects the empirical observation that plants in very cold habitats typically have low maximum rates
    # T1 = 0.8 + 0.02 * Topt - 0.0005 * Topt ^ 2 this would make sense if Topt would be the same everywhere.
    
	# first half of the response curve
    Tp1 = 𝟙 / (𝟙 + exp(ToptA * (-Texp))) / (𝟙 + exp(ToptA * (-Texp)))
    TC1 = 𝟙 / Tp1
    T1 = TC1 / (𝟙 + exp(ToptA * (Topt - Texp - TairDay))) / (𝟙 + exp(ToptA * (-Topt - Texp + TairDay)))

    # second half of the response curve
    Tp2 = 𝟙 / (𝟙 + exp(ToptB * (-Texp))) / (𝟙 + exp(ToptB * (-Texp)))
    TC2 = 𝟙 / Tp2
    T2 = TC2 / (𝟙 + exp(ToptB * (Topt - Texp - TairDay))) / (𝟙 + exp(ToptB * (-Topt - Texp + TairDay)))

	# get the scalar
    TempScGPP = TairDay >= Topt ? T2 : T1

    ## pack land variables
    @pack_land TempScGPP => land.gppAirT
    return land
end

@doc """
temperature stress for gppPot based on CASA & Potter

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of temperature using gppAirT_CASA

*Inputs*
 - forcing.TairDay: daytime temperature [°C]

*Outputs*
 - land.gppDirRadiation.LightScGPP: effect of light saturation on potential GPP

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