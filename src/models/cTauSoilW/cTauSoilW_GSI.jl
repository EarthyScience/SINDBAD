export cTauSoilW_GSI

@bounds @describe @units @with_kw struct cTauSoilW_GSI{T1, T2, T3} <: cTauSoilW
	Wopt::T1 = 90.0 | (60.0, 95.0) | "Optimal moisture for decomposition" | "percent degree of saturation"
	WoptA::T2 = 0.2 | (0.1, 0.3) | "slope of increase" | "per percent"
	WoptB::T3 = 0.3 | (0.15, 0.5) | "slope of decrease" | "per percent"
end

function precompute(o::cTauSoilW_GSI, forcing, land, helpers)
	@unpack_cTauSoilW_GSI o

	## instantiate variables
	p_fsoilW = ones(helpers.numbers.numType, length(land.pools.cEco))

	## pack land variables
	@pack_land p_fsoilW => land.cTauSoilW
	return land
end

function compute(o::cTauSoilW_GSI, forcing, land, helpers)
	## unpack parameters
	@unpack_cTauSoilW_GSI o

	## unpack land variables
	@unpack_land p_fsoilW ∈ land.cTauSoilW

	## unpack land variables
	@unpack_land begin
		p_wSat ∈ land.soilWBase
		soilW ∈ land.pools
	end
	# get the parameters
	WOPT = Wopt
	A = WoptA
	B = WoptB
	## for the litter pools; only use the top layer"s moisture
	soilW_top = 100 * soilW[1] / p_wSat[1]
	# first half of the response curve
	W2p1 = 1 / (1 + exp(A * (-10.0))) / (1 + exp(A * (- 10.0)))
	W2C1 = 1 / W2p1
	W21 = W2C1 / (1 + exp(A * (WOPT - 10 - soilW_top))) / (1 + exp(A * (- WOPT - 10 + soilW_top)))
	# second half of the response curve
	W2p2 = 1 / (1 + exp(B * (-10.0))) / (1 + exp(B * (- 10.0)))
	W2C2 = 1 / W2p2
	T22 = W2C2 / (1 + exp(B * (WOPT - 10 - soilW_top))) / (1 + exp(B * (- WOPT - 10 + soilW_top)))
	# combine the response curves
	v = soilW_top >= WOPT
	T2 = W21
	T2[v] = T22[v]
	# assign it to the array
	soilW1_sc = T2
	for cL in helpers.pools.carbon.zix.cLit
		p_fsoilW[cL] = soilW1_sc
	end
	## repeat for the soil pools; using all soil moisture layers
	soilW_all = 100 * sum(soilW) / sum(p_wSat)
	# first half of the response curve
	W2p1 = 1 / (1 + exp(A * (-10.0))) / (1 + exp(A * (- 10.0)))
	W2C1 = 1 / W2p1
	W21 = W2C1 / (1 + exp(A * (WOPT - 10 - soilW_all))) / (1 + exp(A * (- WOPT - 10 + soilW_all)))
	# second half of the response curve
	W2p2 = 1 / (1 + exp(B * (-10.0))) / (1 + exp(B * (- 10.0)))
	W2C2 = 1 / W2p2
	T22 = W2C2 / (1 + exp(B * (WOPT - 10 - soilW_all))) / (1 + exp(B * (- WOPT - 10 + soilW_all)))
	# combine the response curves
	v = soilW_all >= WOPT
	T2 = W21
	T2[v] = T22[v]
	# assign it to the array
	soilW_all_sc = T2
	for cS in helpers.pools.carbon.zix.cSoil
		p_fsoilW[cS] = soilW_all_sc
	end
	fsoilW = soilW_all_sc

	## pack land variables
	@pack_land (fsoilW, p_fsoilW) => land.cTauSoilW
	return land
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