export cAllocationTreeFraction_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationTreeFraction_Friedlingstein1999{T1} <: cAllocationTreeFraction
	Rf2Rc::T1 = 1.0 | (0.0, 1.0) | "carbon fraction allocated to fine roots" | "fraction"
end

function precompute(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    ## calculate variables
    # check if there are fine & coarse root pools
    if hasproperty(land.pools, :cVegWoodC) && hasproperty(land.pools, :cVegWoodF)
        cpNamesTFAlloc = (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)
    else
        cpNamesTFAlloc = (:cVegRoot, :cVegWood, :cVegLeaf)
    end
    @pack_land cpNamesTFAlloc => land.states
    return land
end

function setCAlloc(cAlloc, cAllocValue, landPools, poolName)
    zix = first(parentindices(getfield(landPools, poolName)))
    for ix in zix
        cAlloc[ix] = cAllocValue * cAlloc[ix]
    end
end


function compute(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationTreeFraction_Friedlingstein1999 o

    ## unpack land variables
    @unpack_land begin
        (cAlloc, treeFraction, cpNamesTFAlloc) ∈ land.states
        (𝟘, 𝟙) ∈ helpers.numbers
    end


    # the allocation fractions according to the partitioning to root/wood/leaf - represents plant level allocation
    r0 = zero(eltype(cAlloc)) 
    for ix in getzix(land.pools.cVegRoot)
        r0 = r0 + cAlloc[ix]
    end
    s0 = zero(eltype(cAlloc)) 
    for ix in getzix(land.pools.cVegWood)
        s0 = s0 + cAlloc[ix]
    end
    l0 = zero(eltype(cAlloc)) 
    for ix in getzix(land.pools.cVegLeaf)
        l0 = l0 + cAlloc[ix]
    end     # this is to below ground root fine+coarse
    # s0 = 0.2 #sum(@view cAlloc[getzix(land.pools.cVegWood)])
    # l0 = 0.1#sum(@view cAlloc[getzix(land.pools.cVegLeaf)])

	# adjust for spatial consideration of TreeFrac & plant level
    # partitioning between fine & coarse roots
    cVegWood = treeFraction
    cVegRoot = 𝟙 + (s0 / (r0 + l0)) * (𝟙 - treeFraction)
    cVegRootF = cVegRoot * (Rf2Rc * treeFraction + (𝟙 - treeFraction))
    cVegRootC = cVegRoot * (𝟙 - Rf2Rc) * treeFraction
    # cVegRoot = cVegRootF + cVegRootC
    cVegLeaf = 𝟙 + (s0 / (r0 + l0)) * (𝟙 - treeFraction)

    setCAlloc(cAlloc, cVegWood, land.pools, :cVegWood)
    if hasproperty(cpNamesTFAlloc, :cVegRootC)
        setCAlloc(cAlloc, cVegRootC, land.pools, :cVegRootC)
        setCAlloc(cAlloc, cVegRootF, land.pools, :cVegRootF)
    else
        setCAlloc(cAlloc, cVegRoot, land.pools, :cVegRoot)
    end
    setCAlloc(cAlloc, cVegLeaf, land.pools, :cVegLeaf)

    # zix = first(parentindices(getfield(land.pools, :cVegWood)))
    # for ix in zix
    #     cAlloc[ix] = cVegWood * cAlloc[ix]
    # end
    # if hasproperty(cpNamesTFAlloc, :cVegRootC)
    #     zix = first(parentindices(getfield(land.pools, :cVegRootC)))
    #     for ix in zix
    #         cAlloc[ix] = cVegRootC * cAlloc[ix]
    #     end
    #     zix = first(parentindices(getfield(land.pools, :cVegRootF)))
    #     for ix in zix
    #         cAlloc[ix] = cVegRootF * cAlloc[ix]
    #     end
    # else
    #     zix = first(parentindices(getfield(land.pools, :cVegRoot)))
    #     for ix in zix
    #         cAlloc[ix] = cVegRoot * cAlloc[ix]
    #     end
    # end
    # zix = first(parentindices(getfield(land.pools, :cVegLeaf)))
    # for ix in zix
    #     cAlloc[ix] = cVegLeaf * cAlloc[ix]
    # end

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