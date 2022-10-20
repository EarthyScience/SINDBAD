export cAllocationTreeFraction_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationTreeFraction_Friedlingstein1999{T1} <: cAllocationTreeFraction
	Rf2Rc::T1 = 1.0f0 | (0.0f0, 1.0f0) | "carbon fraction allocated to fine roots" | "fraction"
end

function precompute(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land::NamedTuple, helpers::NamedTuple)
    cpNamesTFAlloc = nothing
    if hasproperty(land.pools, :cVegWoodC) && hasproperty(land.pools, :cVegWoodF)
        cpNamesTFAlloc = (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)
    else
        cpNamesTFAlloc = (:cVegRoot, :cVegWood, :cVegLeaf)
    end
    zixTFAlloc = Dict()
    cFTFAlloc = Dict()
    for cpName in cpNamesTFAlloc
        cFTFAlloc[cpName] = helpers.numbers.𝟘
        zixTFAlloc[cpName] = Dict()
        zix = getzix(land.pools, cpName)
        zixTFAlloc[cpName][:zix] = zix
        zixTFAlloc[cpName][:nZix] = length(zix)
    end


    @pack_land (zixTFAlloc, cpNamesTFAlloc, cFTFAlloc) => land.states

    return land
end

function compute(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters
    @unpack_cAllocationTreeFraction_Friedlingstein1999 o

    ## unpack land variables
    @unpack_land begin
        (cAlloc, treeFraction, zixTFAlloc, cpNamesTFAlloc, cFTFAlloc) ∈ land.states
        𝟙 ∈ helpers.numbers
    end

    ## calculate variables
    # check if there are fine & coarse root pools
    # if hasproperty(land.pools, :cVegWoodC) && hasproperty(land.pools, :cVegWoodF)
    #     cpNames = (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)
    # else
    #     cpNames = (:cVegRoot, :cVegWood, :cVegLeaf)
    # end

    # the allocation fractions according to the partitioning to root/wood/leaf - represents plant level allocation
    r0 = sum(@view cAlloc[zixTFAlloc[:cVegRoot][:zix]]) # this is to below ground root fine+coarse
    s0 = sum(@view cAlloc[zixTFAlloc[:cVegWood][:zix]])
    l0 = sum(@view cAlloc[zixTFAlloc[:cVegLeaf][:zix]])

	# adjust for spatial consideration of TreeFrac & plant level
    # partitioning between fine & coarse roots
    cVegWood = treeFraction
    cFTFAlloc[:cVegWood] = cVegWood

    cVegRoot = 𝟙 + (s0 / (r0 + l0)) * (𝟙 - treeFraction)
    cFTFAlloc[:cVegRoot] = cVegRoot

    if :cVegRootC in cpNamesTFAlloc
        cVegRootC = cVegRoot * (𝟙 - Rf2Rc) * treeFraction
        cFTFAlloc[:cVegRootC] = cVegRootC
    end

    if :cVegRootF in cpNamesTFAlloc
        cVegRootF = cVegRoot * (Rf2Rc * treeFraction + (𝟙 - treeFraction))
        cFTFAlloc[:cVegRootF] = cVegRootF
    end
        
    # cVegRoot = cVegRootF + cVegRootC
    cVegLeaf = 𝟙 + (s0 / (r0 + l0)) * (𝟙 - treeFraction)
    cFTFAlloc[:cVegLeaf] = cVegLeaf

    # cF = (; cVegWood=cVegWood, cVegRootF=cVegRootF, cVegRootC=cVegRootC, cVegRoot=cVegRoot, cVegLeaf=cVegLeaf)
    

	# adjust the allocation parameters
    for cpName in cpNamesTFAlloc
        zix = zixTFAlloc[cpName][:zix]
        for zv in eachindex(zix)
            cAlloc[zix[zv]] = cFTFAlloc[cpName][1] * cAlloc[zix[zv]][1]
        end
    end

    ## pack land variables
    # @pack_land begin
    #     cAlloc => land.states
    # end
    # @show cAlloc, sum(cAlloc)
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