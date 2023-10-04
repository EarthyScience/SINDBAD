export cTauSoilW_GSI

#! format: off
@bounds @describe @units @with_kw struct cTauSoilW_GSI{T1,T2,T3,T4,T5} <: cTauSoilW
    Wopt::T1 = 90.0 | (60.0, 95.0) | "Optimal moisture for decomposition" | "percent degree of saturation"
    WoptA::T2 = 0.2 | (0.1, 0.3) | "slope of increase" | "per percent"
    WoptB::T3 = 0.3 | (0.15, 0.5) | "slope of decrease" | "per percent"
    Wexp::T4 = 10.0 | (-Inf, Inf) | "reference for exponent of sensitivity" | "per percent"
    frac2perc::T5 = 100.0 | (-Inf, Inf) | "unit converter for fraction to percent" | ""
end
#! format: on

function define(p_struct::cTauSoilW_GSI, forcing, land, helpers)
    @unpack_cTauSoilW_GSI p_struct

    ## instantiate variables
    c_eco_k_f_soilW = one.(land.pools.cEco)

    ## pack land variables
    @pack_land c_eco_k_f_soilW => land.cTauSoilW
    return land
end

function compute(p_struct::cTauSoilW_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cTauSoilW_GSI p_struct

    ## unpack land variables
    @unpack_land c_eco_k_f_soilW ∈ land.cTauSoilW

    ## unpack land variables
    @unpack_land begin
        wSat ∈ land.soilWBase
        soilW ∈ land.pools
    end
    w_one = one(eltype(soilW))
    ## for the litter pools; only use the top layer"s moisture
    soilW_top = min(frac2perc * soilW[1] / wSat[1], frac2perc)
    soilW_top_sc = fSoilW_cTau(w_one, WoptA, WoptB, Wexp, Wopt, soilW_top)
    cLitZix = getZix(land.pools.cLit, helpers.pools.zix.cLit)
    for l_zix ∈ cLitZix
        @rep_elem soilW_top_sc => (c_eco_k_f_soilW, l_zix, :cEco)
    end

    ## repeat for the soil pools; using all soil moisture layers
    soilW_all = min(frac2perc * sum(soilW) / sum(wSat), frac2perc)
    soilW_all_sc = fSoilW_cTau(w_one, WoptA, WoptB, Wexp, Wopt, soilW_all)

    cSoilZix = getZix(land.pools.cSoil, helpers.pools.zix.cSoil)
    for s_zix ∈ cSoilZix
        @rep_elem soilW_all_sc => (c_eco_k_f_soilW, s_zix, :cEco)
    end

    ## pack land variables
    @pack_land c_eco_k_f_soilW => land.cTauSoilW
    return land
end

function fSoilW_cTau(the_one, A, B, wExp, wOpt, wSoil)
    # first half of the response curve
    W2p1 = the_one / ((the_one + exp(A * -wExp)) * (the_one + exp(A * -wExp)))
    W2C1 = the_one / W2p1
    W21 = W2C1 / ((the_one + exp(A * (wOpt - wExp - wSoil))) * (the_one + exp(A * (-wOpt - wExp + wSoil))))

    # second half of the response curve
    W2p2 = the_one / ((the_one + exp(B * -wExp)) * (the_one + exp(B * -wExp)))
    W2C2 = the_one / W2p2
    T22 = W2C2 / ((the_one + exp(B * (wOpt - wExp - wSoil))) * (the_one + exp(B * (-wOpt - wExp + wSoil))))

    # combine the response curves
    soilW_sc = wSoil >= wOpt ? T22 : W21
    return soilW_sc
end

@doc """
calculate the moisture stress for cTau based on temperature stressor function of CASA & Potter

# Parameters
$(SindbadParameters)

---

# compute:
Effect of soil moisture on decomposition rates using cTauSoilW_GSI

*Inputs*
 - land.pools.soilW: soil temperature

*Outputs*
 - land.cTauSoilW.c_eco_k_f_soilW: effect of moisture on cTau for different pools

# instantiate:
instantiate/instantiate time-invariant variables for cTauSoilW_GSI


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
