export cAllocationTreeFraction_Friedlingstein1999

#! format: off
@bounds @describe @units @with_kw struct cAllocationTreeFraction_Friedlingstein1999{T1} <: cAllocationTreeFraction
    Rf2Rc::T1 = 1.0 | (0.0, 1.0) | "carbon fraction allocated to fine roots" | "fraction"
end
#! format: on

function define(p_struct::cAllocationTreeFraction_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    ## calculate variables
    # check if there are fine & coarse root pools
    cVeg_names_for_c_allocation_frac_tree = (:cVegRoot, :cVegWood, :cVegLeaf)::Tuple
    if hasproperty(land.pools, :cVegWoodC) && hasproperty(land.pools, :cVegWoodF)
        cVeg_names_for_c_allocation_frac_tree = (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)::Tuple
    end
    @pack_land cVeg_names_for_c_allocation_frac_tree => land.cAllocationTreeFraction
    return land
end

function setCAlloc(c_allocation, cAllocValue, landPool, zixPools, helpers)
    zix = getZix(landPool, zixPools)
    for ix ∈ eachindex(zix)
        @rep_elem cAllocValue * c_allocation[zix[ix]] => (c_allocation, zix[ix], :cEco)
    end
    return c_allocation
end

function compute(p_struct::cAllocationTreeFraction_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationTreeFraction_Friedlingstein1999 p_struct

    ## unpack land variables
    @unpack_land begin
        (c_allocation, frac_tree) ∈ land.states
        cVeg_names_for_c_allocation_frac_tree ∈ land.cAllocationTreeFraction
        (z_zero, o_one) ∈ land.wCycleBase
    end
    # the allocation fractions according to the partitioning to root/wood/leaf - represents plant level allocation
    _pools = land.pools
    _zix_pools = helpers.pools.zix

    r0 = inner_rsl(z_zero, _pools.cVegRoot, _zix_pools.cVegRoot, c_allocation)
    s0 = inner_rsl(z_zero, _pools.cVegWood, _zix_pools.cVegWood, c_allocation)
    l0 = inner_rsl(z_zero, _pools.cVegLeaf, _zix_pools.cVegLeaf, c_allocation)

    # this is to below ground root fine+coarse

    # adjust for spatial consideration of TreeFrac & plant level
    # partitioning between fine & coarse roots
    o_one = one(eltype(c_allocation))
    a_cVegWood = frac_tree
    a_cVegRoot = o_one + (s0 / (r0 + l0)) * (o_one - frac_tree)
    a_cVegRootF = a_cVegRoot * (Rf2Rc * frac_tree + (o_one - frac_tree))
    a_cVegRootC = a_cVegRoot * (o_one - Rf2Rc) * frac_tree
    # cVegRoot = cVegRootF + cVegRootC
    a_cVegLeaf = o_one + (s0 / (r0 + l0)) * (o_one - frac_tree)

    c_allocation = setCAlloc(c_allocation, a_cVegWood, land.pools.cVegWood, helpers.pools.zix.cVegWood, helpers)
    has_p = hasproperty(cVeg_names_for_c_allocation_frac_tree, :cVegRootC)

    c_allocation = inner_has(
        has_p,
        c_allocation,
        a_cVegRoot,
        a_cVegRootC,
        a_cVegRootF,
        land.pools,
        helpers.pools.zix,
        helpers)

    c_allocation = setCAlloc(c_allocation, a_cVegLeaf, land.pools.cVegLeaf, helpers.pools.zix.cVegLeaf, helpers)

    @pack_land c_allocation => land.states

    return land
end

function inner_rsl(rsl, _cVeg_type, _zix_Veg_type, c_allocation)
    for ix ∈ getZix(_cVeg_type, _zix_Veg_type)
        rsl = rsl + c_allocation[ix]
    end
    return rsl
end

function inner_has(
    has_p,
    c_allocation,
    a_cVegRoot,
    a_cVegRootC,
    a_cVegRootF,
    _pools,
    _zix_pools,
    helpers)

    if has_p
        c_allocation = setCAlloc(c_allocation, a_cVegRootC, _pools.cVegRootC, _zix_pools.cVegRootC, helpers)
        c_allocation = setCAlloc(c_allocation, a_cVegRootF, _pools.cVegRootF, _zix_pools.cVegRootF, helpers)
    else
        c_allocation = setCAlloc(c_allocation, a_cVegRoot, _pools.cVegRoot, _zix_pools.cVegRoot, helpers)
    end
    return c_allocation
end

@doc """
adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - land.states.c_allocation: the fraction of npp that is allocated to the different plant organs
 - land.states.frac_tree: tree cover

*Outputs*
 - land.states.c_allocation: adjusted fraction of npp that is allocated to the different plant organs

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
