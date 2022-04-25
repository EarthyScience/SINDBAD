export cAllocationTreeFraction_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationTreeFraction_Friedlingstein1999{T1} <: cAllocationTreeFraction
	Rf2Rc::T1 = 1.0 | (0.0, 1.0) | "fine root to coarse root fraction" | "fraction"
end

function compute(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationTreeFraction_Friedlingstein1999 o

    ## unpack land variables
    @unpack_land begin
        (cAlloc, treeFraction) ∈ land.states
        𝟙 ∈ helpers.numbers
    end

    ## calculate variables
    # check if there are fine & coarse root pools
    if hasproperty(land.pools, :cVegWoodC) && hasproperty(land.pools, :cVegWoodF)
        cpNames = (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)
    else
        cpNames = (:cVegRoot, :cVegWood, :cVegLeaf)
    end

    # the allocation fractions according to the partitioning to root/wood/leaf - represents plant level allocation
    r0 = sum(cAlloc[getzix(land.pools.cVegRoot)]) # this is to below ground root fine+coarse
    s0 = sum(cAlloc[getzix(land.pools.cVegWood)])
    l0 = sum(cAlloc[getzix(land.pools.cVegLeaf)])

	# adjust for spatial consideration of TreeFrac & plant level
    # partitioning between fine & coarse roots
    cVegWood = treeFraction
    cVegRootF = treeFraction * Rf2Rc + (r0 + s0 * (r0 / (r0 + l0))) * (𝟙 - treeFraction)
    cVegRootC = treeFraction * (𝟙 - Rf2Rc)
    cVegRoot = cVegRootF + cVegRootC
    cVegLeaf = treeFraction + (l0 + s0 * (l0 / (r0 + l0))) * (𝟙 - treeFraction)
    cF = (; cVegWood=cVegWood, cVegRootF=cVegRootF, cVegRootC=cVegRootC, cVegRoot=cVegRoot, cVegLeaf=cVegLeaf)

	# adjust the allocation parameters
    for cpName in cpNames
        zix = getzix(land.pools, cpName)
        cAlloc[zix] .= getfield(cF, cpName) .* cAlloc[zix]
    end

    ## pack land variables
    @pack_land begin
        cAlloc => land.states
    end
    return land
end

@doc """
adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - land.states.cAlloc: the fraction of NPP that is allocated to the different plant organs
 - land.states.treeFraction: tree cover

*Outputs*
 - land.states.cAlloc: adjusted fraction of NPP that is allocated to the different plant organs

---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocationTreeFraction_Friedlingstein1999