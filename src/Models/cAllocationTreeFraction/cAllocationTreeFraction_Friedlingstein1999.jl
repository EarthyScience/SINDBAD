export cAllocationTreeFraction_Friedlingstein1999

#! format: off
@bounds @describe @units @with_kw struct cAllocationTreeFraction_Friedlingstein1999{T1} <: cAllocationTreeFraction
    Rf2Rc::T1 = 1.0 | (0.0, 1.0) | "carbon fraction allocated to fine roots" | "fraction"
end
#! format: on

function define(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    ## calculate variables
    # check if there are fine & coarse root pools
    if hasproperty(land.pools, :cVegWoodC) && hasproperty(land.pools, :cVegWoodF)
        cpNamesTFAlloc = (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)
    else
        cpNamesTFAlloc = (:cVegRoot, :cVegWood, :cVegLeaf)
    end
    @pack_land cpNamesTFAlloc => land.cAllocationTreeFraction
    return land
end

function setCAlloc(cAlloc, cAllocValue, landPool, zixPools, helpers)
    zix = getzix(landPool, zixPools)
    for ix ∈ eachindex(zix)
        @rep_elem cAllocValue * cAlloc[zix[ix]] => (cAlloc, zix[ix], :cEco)
    end
    return cAlloc
end

function compute(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationTreeFraction_Friedlingstein1999 o

    ## unpack land variables
    @unpack_land begin
        (cAlloc, treeFraction) ∈ land.states
        cpNamesTFAlloc ∈ land.cAllocationTreeFraction
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    # the allocation fractions according to the partitioning to root/wood/leaf - represents plant level allocation
    r0 = zero(eltype(cAlloc))
    for ix ∈ getzix(land.pools.cVegRoot, helpers.pools.zix.cVegRoot)
        r0 = r0 + cAlloc[ix]
    end
    s0 = zero(eltype(cAlloc))
    for ix ∈ getzix(land.pools.cVegWood, helpers.pools.zix.cVegWood)
        s0 = s0 + cAlloc[ix]
    end
    l0 = zero(eltype(cAlloc))
    for ix ∈ getzix(land.pools.cVegLeaf, helpers.pools.zix.cVegLeaf)
        l0 = l0 + cAlloc[ix]
    end     # this is to below ground root fine+coarse

    # adjust for spatial consideration of TreeFrac & plant level
    # partitioning between fine & coarse roots
    cVegWood = treeFraction
    cVegRoot = 𝟙 + (s0 / (r0 + l0)) * (𝟙 - treeFraction)
    cVegRootF = cVegRoot * (Rf2Rc * treeFraction + (𝟙 - treeFraction))
    cVegRootC = cVegRoot * (𝟙 - Rf2Rc) * treeFraction
    # cVegRoot = cVegRootF + cVegRootC
    cVegLeaf = 𝟙 + (s0 / (r0 + l0)) * (𝟙 - treeFraction)

    cAlloc = setCAlloc(cAlloc, cVegWood, land.pools.cVegWood, helpers.pools.zix.cVegWood, helpers)
    if hasproperty(cpNamesTFAlloc, :cVegRootC)
        cAlloc = setCAlloc(cAlloc, cVegRootC, land.pools.cVegRootC, helpers.pools.zix.cVegRootC,
            helpers)
        cAlloc = setCAlloc(cAlloc, cVegRootF, land.pools.cVegRootF, helpers.pools.zix.cVegRootF,
            helpers)
    else
        cAlloc = setCAlloc(cAlloc, cVegRoot, land.pools.cVegRoot, helpers.pools.zix.cVegRoot,
            helpers)
    end

    cAlloc = setCAlloc(cAlloc, cVegLeaf, land.pools.cVegLeaf, helpers.pools.zix.cVegLeaf, helpers)

    @pack_land cAlloc => land.states

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
