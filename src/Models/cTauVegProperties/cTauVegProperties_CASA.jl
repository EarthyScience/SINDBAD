export cTauVegProperties_CASA

#! format: off
@bounds @describe @units @with_kw struct cTauVegProperties_CASA{T1,T2,T3,T4,T5,T6,T7} <: cTauVegProperties
    LIGNIN_per_PFT::T1 = Float64[0.2, 0.2, 0.22, 0.25, 0.2, 0.15, 0.1, 0.0, 0.2, 0.15, 0.15, 0.1] | nothing | "fraction of litter that is lignin" | ""
    NONSOL2SOLLIGNIN::T2 = 2.22 | nothing | "" | ""
    MTFA::T3 = 0.85 | nothing | "" | ""
    MTFB::T4 = 0.018 | nothing | "" | ""
    C2LIGNIN::T5 = 0.65 | nothing | "" | ""
    LIGEFFA::T6 = 3.0 | nothing | "" | ""
    LITC2N_per_PFT::T7 = Float64[40.0, 50.0, 65.0, 80.0, 50.0, 50.0, 50.0, 0.0, 65.0, 50.0, 50.0, 40.0] | nothing | "carbon-to-nitrogen ratio in litter" | ""
end
#! format: on

function define(o::cTauVegProperties_CASA, forcing, land, helpers)
    @unpack_cTauVegProperties_CASA o

    @unpack_land (𝟘, num_type) ∈ helpers.numbers

    ## instantiate variables
    p_kfVeg = zero(land.pools.cEco) .+ helpers.numbers.𝟙 #sujan
    annk = 𝟘#sujan ones(size(AGE))

    ## pack land variables
    @pack_land (p_kfVeg, annk) => land.cTauVegProperties
    return land
end

function compute(o::cTauVegProperties_CASA, forcing, land, helpers)
    ## unpack parameters
    @unpack_cTauVegProperties_CASA o

    ## unpack land variables
    @unpack_land begin
        PFT ∈ land.vegProperties
        (p_kfVeg, annk) ∈ land.cTauVegProperties
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    ## calculate variables
    # p_annk = annk; #sujan
    # initialize the outputs to ones
    p_C2LIGNIN = C2LIGNIN #sujan
    ## adjust the annk that are pft dependent directly on the p matrix
    pftVec = unique(PFT)
    # AGE = zeros(num_type, length(land.pools.cEco)); #sujan
    for cpN ∈ (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)
        # get average age from parameters
        AGE = 𝟘 #sujan
        for ij ∈ eachindex(pftVec)
            AGE[p.vegProperties.PFT==pftVec[ij]] = p.cCycleBase.([cpN "_AGE_per_PFT"])(pftVec[ij])
        end
        # compute annk based on age
        annk[AGE>𝟘] = 𝟙 / AGE[AGE>𝟘]
        # feed it to the new annual turnover rates
        zix = helpers.pools.zix.(cpN)
        p_annk[zix] = annk #sujan
        # p_annk[zix] = annk[zix]
    end
    # feed the parameters that are pft dependent.
    pftVec = unique(PFT)
    p_LITC2N = 𝟘
    p_LIGNIN = 𝟘
    for ij ∈ eachindex(pftVec)
        p_LITC2N[p.vegProperties.PFT==pftVec[ij]] = LITC2N_per_PFT[pftVec[ij]]
        p_LIGNIN[p.vegProperties.PFT==pftVec[ij]] = LIGNIN_per_PFT[pftVec[ij]]
    end
    # CALCULATE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
    # CALCULATE LIGNIN 2 NITROGEN SCALAR
    L2N = (p_LITC2N * p_LIGNIN) * NONSOL2SOLLIGNIN
    # DETERMINE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
    MTF = MTFA - (MTFB * L2N)
    MTF[MTF<𝟘] = 𝟘
    p_MTF = MTF
    # DETERMINE FRACTION OF C IN STRUCTURAL LITTER POOLS FROM LIGNIN
    p_SCLIGNIN = (p_LIGNIN * p_C2LIGNIN * NONSOL2SOLLIGNIN) / (𝟙 - MTF)
    # DETERMINE EFFECT OF LIGNIN CONTENT ON k OF cLitLeafS AND cLitRootFS
    p_LIGEFF = exp(-LIGEFFA * p_SCLIGNIN)
    # feed the output
    p_kfVeg[helpers.pools.zix.cLitLeafS] = p_LIGEFF
    p_kfVeg[helpers.pools.zix.cLitRootFS] = p_LIGEFF

    ## pack land variables
    @pack_land begin
        p_annk => land.cCycleBase
        (p_C2LIGNIN, p_LIGEFF, p_LIGNIN, p_LITC2N, p_MTF, p_SCLIGNIN, p_kfVeg) =>
            land.cTauVegProperties
    end
    return land
end

@doc """
Compute effect of vegetation type on turnover rates [k]

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of vegetation properties on soil decomposition rates using cTauVegProperties_CASA

*Inputs*
 - land.vegProperties.PFT:

*Outputs*
 - land.cTauVegProperties.p_LIGEFF:
 - land.cTauVegProperties.p_LIGNIN:
 - land.cTauVegProperties.p_LITC2N:
 - land.cTauVegProperties.p_MTF:
 - land.cTauVegProperties.p_SCLIGNIN:
 - land.cTauVegProperties.p_kfVeg:

# instantiate:
instantiate/instantiate time-invariant variables for cTauVegProperties_CASA


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cTauVegProperties_CASA
