export cTauSoilW_GSI

@bounds @describe @units @with_kw struct cTauSoilW_GSI{T1, T2, T3, T4, T5} <: cTauSoilW
	Wopt::T1 = 90.0f0 | (60.0f0, 95.0f0) | "Optimal moisture for decomposition" | "percent degree of saturation"
	WoptA::T2 = 0.2f0 | (0.1f0, 0.3f0) | "slope of increase" | "per percent"
	WoptB::T3 = 0.3f0 | (0.15f0, 0.5f0) | "slope of decrease" | "per percent"
	Wexp::T4 = 10.0f0 | (nothing, nothing) | "reference for exponent of sensitivity" | "per percent"
	frac2perc::T5 = 100.0f0 | (nothing, nothing) | "unit converter for fraction to percent" | ""
end

function precompute(o::cTauSoilW_GSI, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_cTauSoilW_GSI o

	## instantiate variables
	p_fsoilW = ones(helpers.numbers.numType, length(land.pools.cEco))

	## pack land variables
	@pack_land p_fsoilW => land.cTauSoilW
	return land
end


function compute(o::cTauSoilW_GSI, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters
    @unpack_cTauSoilW_GSI o

    ## unpack land variables
    @unpack_land p_fsoilW ∈ land.cTauSoilW

    ## unpack land variables
    @unpack_land begin
        p_wSat ∈ land.soilWBase
        soilW ∈ land.pools
        𝟙 ∈ helpers.numbers
    end

	## for the litter pools; only use the top layer"s moisture
    soilW_top = frac2perc * soilW[1] / p_wSat[1]
    soilW_top_sc = fSoilW_cTau(𝟙, WoptA, WoptB, Wexp, Wopt, soilW_top)
    p_fsoilW[getzix(land.pools.cLit)] .= soilW_top_sc


    ## repeat for the soil pools; using all soil moisture layers
    soilW_all = 100 * sum(soilW) / sum(p_wSat)
    soilW_all_sc = fSoilW_cTau(𝟙, WoptA, WoptB, Wexp, Wopt, soilW_all)
    p_fsoilW[getzix(land.pools.cSoil)] .= soilW_all_sc


    ## pack land variables
    @pack_land (p_fsoilW) => land.cTauSoilW
    return land
end

function fSoilW_cTau(𝟙, A, B, wExp, wOpt, wSoil)
	# first half of the response curve
	W2p1 = 𝟙 / (𝟙 + exp(A * (-wExp))) / (𝟙 + exp(A * (-wExp)))
    W2C1 = 𝟙 / W2p1
    W21 = W2C1 / (𝟙 + exp(A * (wOpt - wExp - wSoil))) / (𝟙 + exp(A * (-wOpt - wExp + wSoil)))

    # second half of the response curve
    W2p2 = 𝟙 / (𝟙 + exp(B * (-wExp))) / (𝟙 + exp(B * (-wExp)))
    W2C2 = 𝟙 / W2p2
    T22 = W2C2 / (𝟙 + exp(B * (wOpt - wExp - wSoil))) / (𝟙 + exp(B * (-wOpt - wExp + wSoil)))

    # combine the response curves
    soilW_sc = wSoil >= wOpt ? T22 : W21
	return soilW_sc
end


@doc """
calculate the moisture stress for cTau based on temperature stressor function of CASA & Potter

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of soil moisture on decomposition rates using cTauSoilW_GSI

*Inputs*
 - land.pools.soilW: soil temperature

*Outputs*
 - land.cTauSoilW.p_fsoilW: effect of moisture on cTau for different pools

# precompute:
precompute/instantiate time-invariant variables for cTauSoilW_GSI


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 12.02.2021 [skoirala]

*Created by:*
 - skoirala

*Notes*
"""
cTauSoilW_GSI