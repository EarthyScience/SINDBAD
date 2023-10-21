export cFlowVegProperties_CASA

#! format: off
@bounds @describe @units @with_kw struct cFlowVegProperties_CASA{T1} <: cFlowVegProperties
    frac_lignin_wood::T1 = 0.4 | (-Inf, Inf) | "fraction of wood that is lignin" | ""
end
#! format: on

function define(params::cFlowVegProperties_CASA, forcing, land, helpers)
    @unpack_cFlowVegProperties_CASA params
    c_taker ∈ land.cCycleBase

    ## instantiate variables
    p_F_vec = eltype(land.pools.cEco).(zero([c_taker...]))
    if land.pools.cEco isa SVector
        p_F_vec = SVector{length(p_F_vec)}(p_F_vec)
    end

    ## pack land variables
    @pack_land p_F_vec → land.cFlowVegProperties
    return land
end

function compute(params::cFlowVegProperties_CASA, forcing, land, helpers)
    ## unpack parameters
    @unpack_cFlowVegProperties_CASA params

    ## unpack land variables
    @unpack_land p_F_vec ∈ land.cFlowVegProperties

    ## calculate variables
    # p_fVeg = zeros(nPix, length(info.model.c.nZix)); #sujan
    #p_fVeg = zero(land.pools.cEco)
    p_E_vec = p_F_vec
    # ADJUST cFlow BASED ON PARTICULAR PARAMETERS # SOURCE, TARGET, INCREMENT aM = (:cVegLeaf, :cLitLeafM, MTF;, :cVegLeaf, :cLitLeafS, 1, -, MTF;, :cVegWood, :cLitWood, 1;, :cVegRootF, :cLitRootFM, MTF;, :cVegRootF, :cLitRootFS, 1, -, MTF;, :cVegRootC, :cLitRootC, 1;, :cLitLeafS, :cSoilSlow, SCLIGNIN;, :cLitLeafS, :cMicSurf, 1, -, SCLIGNIN;, :cLitRootFS, :cSoilSlow, SCLIGNIN;, :cLitRootFS, :cMicSoil, 1, -, SCLIGNIN;, :cLitWood, :cSoilSlow, frac_lignin_wood;, :cLitWood, :cMicSurf, 1, -, frac_lignin_wood;, :cLitRootC, :cSoilSlow, frac_lignin_wood;, :cLitRootC, :cMicSoil, 1, -, frac_lignin_wood;, :cSoilOld, :cMicSoil, 1;, :cLitLeafM, :cMicSurf, 1;, :cLitRootFM, :cMicSoil, 1;, :cMicSurf, :cSoilSlow, 1;)
    for ii ∈ 1:size(aM, 1)
        ndxSrc = helpers.pools.zix.(aM[ii, 1])
        ndxTrg = helpers.pools.zix.(aM[ii, 2]) #sujan is this 2 | 1?
        for iSrc ∈ eachindex(ndxSrc)
            for iTrg ∈ eachindex(ndxTrg)
                # p_fVeg[ndxTrg[iTrg], ndxSrc[iSrc]] = aM(ii, 3)
                p_F_vec[ndxTrg[iTrg], ndxSrc[iSrc]] = aM[ii, 3] #sujan
            end
        end
    end

    ## pack land variables
    @pack_land (p_E_vec, p_F_vec) → land.cFlowVegProperties
    return land
end

@doc """
effects of vegetation that change the transfers between carbon pools

# Parameters
$(SindbadParameters)

---

# compute:
Effect of vegetation properties on the c transfers between pools using cFlowVegProperties_CASA

*Inputs*
 - land.properties.MTF: fraction of C in structural litter pools  that will be metabolic from lignin:N ratio
 - land.properties.SCLIGNIN: fraction of C in structural litter pools from lignin

*Outputs*
 - land.cFlowVegProperties.p_E_vec: effect of vegetation on transfer efficiency between pools
 - land.cFlowVegProperties.p_F_vec: effect of vegetation on transfer fraction between pools
 - land.cFlowVegProperties.p_E_vec
 - land.cFlowVegProperties.p_F_vec

# instantiate:
instantiate/instantiate time-invariant variables for cFlowVegProperties_CASA


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 13.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cFlowVegProperties_CASA
