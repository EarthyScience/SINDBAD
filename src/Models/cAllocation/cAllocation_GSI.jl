export cAllocation_GSI

struct cAllocation_GSI <: cAllocation end

function define(p_struct::cAllocation_GSI, forcing, land, helpers)
    @unpack_land sNT ∈ helpers.numbers

    ## instantiate variables
    c_allocation = zero(land.pools.cEco)
    cVeg_names = (:cVegRoot, :cVegWood, :cVegLeaf)

    c_allocation_to_veg = zero(land.pools.cEco)
    zix_vegs = Tuple{Int}[]
    nzix_vegs = helpers.numbers.num_type[]
    cpI = 1
    for cpName ∈ cVeg_names
        zix = getzix(getfield(land.pools, cpName), getfield(helpers.pools.zix, cpName))
        nZix = sNT(length(zix))
        push!(zix_vegs, zix)
        push!(nzix_vegs, nZix)
    end
    ttwo = sNT(2.0)
    zix_vegs = Tuple(zix_vegs)
    nzix_vegs = Tuple(nzix_vegs)
    ## pack land variables
    @pack_land begin
        (cVeg_names, zix_vegs, nzix_vegs, ttwo) => land.cAllocation
        (c_allocation, c_allocation_to_veg) => land.states
    end
    return land
end

function compute(p_struct::cAllocation_GSI, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (cVeg_names, zix_vegs, nzix_vegs, ttwo) ∈ land.cAllocation
        (c_allocation, c_allocation_to_veg) ∈ land.states
        c_allocation_f_soilW ∈ land.cAllocationSoilW
        c_allocation_f_soilT ∈ land.cAllocationSoilT
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    # allocation to root; wood & leaf
    c_allocation_to_veg_1 = c_allocation_f_soilW / ((c_allocation_f_soilW + c_allocation_f_soilT) * ttwo)
    c_allocation_to_veg_2 = c_allocation_f_soilW / ((c_allocation_f_soilW + c_allocation_f_soilT) * ttwo)
    c_allocation_to_veg_3 = c_allocation_f_soilT / ((c_allocation_f_soilW + c_allocation_f_soilT))

    @rep_elem c_allocation_to_veg_1 => (c_allocation_to_veg, 1, :cEco)
    @rep_elem c_allocation_to_veg_2 => (c_allocation_to_veg, 2, :cEco)
    @rep_elem c_allocation_to_veg_3 => (c_allocation_to_veg, 3, :cEco)

    for ind ∈ 1:3
        zix = zix_vegs[ind]
        nZix = nzix_vegs[ind]
        for ix ∈ eachindex(zix)
            c_allocation_to_veg_ix = c_allocation_to_veg[ind] / nZix
            zix_ix = zix[ix]
            @rep_elem c_allocation_to_veg_ix => (c_allocation, zix_ix, :cEco)
        end
    end

    @pack_land (c_allocation, c_allocation_to_veg) => land.states

    return land
end

@doc """
compute the fraction of npp that is allocated to the different plant organs. In this case; the allocation is dynamic in time according to temperature; water & radiation stressors computed from GSI approach.

---

# compute:
Combine the different effects of carbon allocation using cAllocation_GSI

*Inputs*
 - land.cAllocationRadiation.c_allocation_f_cloud: radiation stressors for carbo allocation
 - land.cAllocationSoilW.c_allocation_f_soilT: temperature stressors for carbon allocation
 - land.cAllocationSoilW.c_allocation_f_soilW: water stressors for carbon allocation

*Outputs*
 - land.states.c_allocation: the fraction of npp that is allocated to the different plant organs
 - land.states.c_allocation

# instantiate:
instantiate/instantiate time-invariant variables for cAllocation_GSI


---

# Extended help

*References*
 - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
 - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology & greenness.
 - Jolly, William M., Ramakrishna Nemani, & Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 [2005]: 619-632.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais & sbesnard

NotesCheck if we can partition C to leaf & wood constrained by interception of light.
"""
cAllocation_GSI
