export cAllocation_Friedlingstein1999

#! format: off
@bounds @describe @units @with_kw struct cAllocation_Friedlingstein1999{T1,T2,T3} <: cAllocation
    so::T1 = 0.3 | (0.0, 1.0) | "" | ""
    ro::T2 = 0.3 | (0.0, 1.0) | "" | ""
    RelY::T3 = 2.0 | (1.0, Inf) | "" | ""
end
#! format: on

function define(p_struct::cAllocation_Friedlingstein1999, forcing, land, helpers)
    @unpack_cAllocation_Friedlingstein1999 p_struct

    ## instantiate variables
    c_allocation = zero(land.pools.cEco) #sujan
    c_allocation_to_veg = zero(land.pools.cEco)
    cVeg_names = (:cVegRoot, :cVegWood, :cVegLeaf)
    cVeg_nzix = []
    cVeg_zix = []
    for cpName ∈ cVeg_names
        zix = getZix(getfield(land.pools, cpName), helpers.pools.zix, cpName)
        nZix = oftype(first(c_allocation), length(zix))
        push!(cVeg_nzix, nZix)
        push!(cVeg_zix, zix)
    end
    cVeg_nzix = Tuple(cVeg_nzix)
    cVeg_zix = Tuple(cVeg_zix)
    ## pack land variables
    @pack_land begin
        c_allocation => land.states
        (cVeg_names, cVeg_nzix, cVeg_zix, c_allocation_to_veg) => land.cAllocation
    end
    return land
end

function compute(p_struct::cAllocation_Friedlingstein1999, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocation_Friedlingstein1999 p_struct

    ## unpack land variables
    @unpack_land begin
        c_allocation ∈ land.states
        (cVeg_names, cVeg_nzix, cVeg_zix, c_allocation_to_veg) ∈ land.cAllocation
        c_allocation_f_W_N ∈ land.cAllocationNutrients
        c_allocation_f_LAI ∈ land.cAllocationLAI
        (z_zero, o_one) ∈ land.wCycleBase
    end
    ## unpack land variables
    # allocation to root; wood & leaf
    a_cVegRoot = ro * (RelY + o_one) * c_allocation_f_LAI / (c_allocation_f_LAI + RelY * c_allocation_f_W_N)
    a_cVegWood = so * (RelY + o_one) * c_allocation_f_W_N / (RelY * c_allocation_f_LAI + c_allocation_f_W_N)
    a_cVegLeaf = o_one - cVegRoot - cVegWood

    @rep_elem a_cVegRoot => (c_allocation_to_veg, 1, :cEco)
    @rep_elem a_cVegWood => (c_allocation_to_veg, 2, :cEco)
    @rep_elem a_cVegLeaf => (c_allocation_to_veg, 3, :cEco)


    # distribute the allocation according to pools
    for cl in eachindex(cVeg_names)
        zix = cVeg_zix[cl]
        nZix = cVeg_nzix[cl]
        for ix ∈ zix
            c_allocation_to_veg_ix = c_allocation_to_veg[cl] / nZix
            @rep_elem c_allocation_to_veg_ix => (c_allocation, ix, :cEco)
        end
    end

    ## pack land variables
    @pack_land c_allocation => land.states
    return land
end

@doc """
compute the fraction of npp that is allocated to the different plant organs following the scheme of Friedlingstein et al 1999. Check cAlloc_Friedlingstein1999 for details.

# Parameters
$(SindbadParameters)

---

# compute:
Combine the different effects of carbon allocation using cAllocation_Friedlingstein1999

*Inputs*
 - land.cAllocationLAI.c_allocation_f_LAI: values for light limitation
 - land.cAllocationNutrients.c_allocation_f_W_N: values for the pseudo-nutrient limitation

*Outputs*
 - land.states.c_allocation: the fraction of npp that is allocated to the different plant organs
 - land.states.c_allocation

# instantiate:
instantiate/instantiate time-invariant variables for cAllocation_Friedlingstein1999


---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocation_Friedlingstein1999
