export cAllocation_fixed

#! format: off
@bounds @describe @units @with_kw struct cAllocation_fixed{T1,T2,T3} <: cAllocation
    a_cVegRoot::T1 = 0.3 | (0.0, 1.0) | "fraction of npp to cRoot" | "fraction"
    a_cVegWood::T2 = 0.3 | (0.0, 1.0) | "fraction of npp to cWood" | "fraction"
    a_cVegLeaf::T3 = 0.4 | (0.0, 1.0) | "fraction of npp to cLeaf" | "fraction"
end
#! format: on

function define(params::cAllocation_fixed, forcing, land, helpers)
    @unpack_cAllocation_fixed params
    ## instantiate variables
    c_allocation = zero(land.pools.cEco) #sujan
    c_allocation_to_veg = zero(land.pools.cEco)
    cVeg_names = (:cVegRoot, :cVegWood, :cVegLeaf)
    cVeg_nzix = []
    cVeg_zix = []
    for cpName ∈ cVeg_names
        zix = getZix(getfield(land.pools.carbon, cpName), helpers.pools.zix, cpName)
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

function precompute(params::cAllocation_fixed, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_cAllocation_fixed params

    @unpack_land begin
        c_allocation ∈ land.states
        (cVeg_names, cVeg_nzix, cVeg_zix, c_allocation_to_veg) ∈ land.cAllocation
    end
    ## unpack land variables
    # allocation to root; wood & leaf

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
compute the fraction of npp that is allocated to the different plant organs. In this case; the allocation is fixed in time according to the parameters in These parameters are adjusted according to the TreeFrac fraction (land.states.frac_tree). Allocation to roots is partitioned into fine [cf2Root] & coarse roots (cf2RootCoarse) according to frac_fine_to_coarse.

# Parameters
$(SindbadParameters)

---

# compute:
Combine the different effects of carbon allocation using cAllocation_fixed

*Inputs*
 - land.c_allocation: fraction of npp that is allocated to the  different plant organs

*Outputs*
 - land.states.c_allocation: the fraction of npp that is allocated to the different plant organs
 - land.states.c_allocation

# instantiate:
instantiate/instantiate time-invariant variables for cAllocation_fixed


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Ciais; P.; Collatz; G.; Mahecha; M. D.  Montagnani; L.; Papale; D.; Rambal; S.; & Seixas; J.: Identification of  Vegetation & Soil Carbon Pools out of Equilibrium in a Process Model  via Eddy Covariance & Biometric Constraints; Glob. Change Biol.; 16  2813?2829; doi: 10.1111/j.1365-2486.2009.2173.x; 2010.#
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocation_fixed
