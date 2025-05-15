export cFlowSoilProperties_CASA

#! format: off
@bounds @describe @units @timescale @with_kw struct cFlowSoilProperties_CASA{T1,T2,T3,T4,T5,T6} <: cFlowSoilProperties
    effA::T1 = 0.85 | (-Inf, Inf) | "" | "" | ""
    effB::T2 = 0.68 | (-Inf, Inf) | "" | "" | ""
    effclay_cMicSoil_A::T3 = 0.003 | (-Inf, Inf) | "" | "" | ""
    effclay_cMicSoil_B::T4 = 0.032 | (-Inf, Inf) | "" | "" | ""
    effclay_cSoilSlow_A::T5 = 0.003 | (-Inf, Inf) | "" | "" | ""
    effclay_cSoilSlow_B::T6 = 0.009 | (-Inf, Inf) | "" | "" | ""
end
#! format: on

function define(params::cFlowSoilProperties_CASA, forcing, land, helpers)
    @unpack_cFlowSoilProperties_CASA params
    @unpack_nt cEco ⇐ land.pools

    ## Instantiate variables
    p_E_vec = repeat(zero(cEco),
        1,
        1,
        length(cEco))

    ## pack land variables
    @pack_nt p_E_vec ⇒ land.diagnostics
    return land
end

function compute(params::cFlowSoilProperties_CASA, forcing, land, helpers)
    ## unpack parameters
    @unpack_cFlowSoilProperties_CASA params

    ## unpack land variables
    @unpack_nt p_E_vec ⇐ land.diagnostics

    ## unpack land variables
    @unpack_nt (st_clay, st_silt) ⇐ land.properties

    ## calculate variables
    # p_fSoil = zeros(length(info.model.nPix), length(info.model.nZix))
    # p_fSoil = zero(cEco)
    # #sujan
    p_F_vec = p_E_vec
    clay = mean(st_clay)
    silt = mean(st_silt)
    # CONTROLS FOR C FLOW TRANSFERS EFFICIENCY [E] AND FRACTION [F] BASED ON PARTICULAR TEXTURE PARAMETERS.
    # SOURCE, TARGET, VALUE [increment in E & F caused by soil properties]
    aME = [:cMicSoil :cSoilSlow effA-(effB*(silt+clay))
        :cMicSoil :cSoilOld effA-(effB*(silt+clay))]
    aMF = [:cSoilSlow :cMicSoil 1-(effclay_cSoilSlow_A+(effclay_cSoilSlow_B*clay))
        :cSoilSlow :cSoilOld effclay_cSoilSlow_A+(effclay_cSoilSlow_B*clay)
        :cMicSoil :cSoilSlow 1-(effclay_cMicSoil_A+(effclay_cMicSoil_B*clay))
        :cMicSoil :cSoilOld effclay_cMicSoil_A+(effclay_cMicSoil_B*clay)]
    for vn ∈ ("E", "F")
        eval(["aM = aM" vn " "])
        for ii ∈ 1:size(aM, 1)
            ndxSrc = helpers.pools.zix.(aM(ii, 1))
            ndxTrg = helpers.pools.zix.(aM(ii, 2))
            for iSrc ∈ eachindex(ndxSrc)
                for iTrg ∈ eachindex(ndxTrg)
                    # (["p_cFlowSoilProperties_" vn(1]])(:, ndxTrg[iTrg], ndxSrc[iSrc]) = aM[ii, 3); #line commented for julia conversion. make sure this works.
                end
            end
        end
    end

    ## pack land variables
    @pack_nt (p_E_vec, p_F_vec) ⇒ land.diagnostics
    return land
end

purpose(::Type{cFlowSoilProperties_CASA}) = "effects of soil that change the transfers between carbon pools"

@doc """

$(getModelDocString(cFlowSoilProperties_CASA))

---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 13.01.2020 [sbesnard]  

*Created by*
 - ncarvalhais
"""
cFlowSoilProperties_CASA
