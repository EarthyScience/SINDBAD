export cAllocation_GSI

struct cAllocation_GSI <: cAllocation end

function precompute(o::cAllocation_GSI, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)
    @unpack_land sNT ∈ helpers.numbers

    ## instantiate variables
    cAlloc = zero(land.pools.cEco)
    cpNames = (:cVegRoot, :cVegWood, :cVegLeaf)

    cAllocVeg = zeros(helpers.numbers.numType, length(cpNames))
    zixVegs = [Int[] for x in cpNames]
    nzixVegs=helpers.numbers.numType[]
    cpI = 1
    for cpName in cpNames
        zix = getzix(land.pools, cpName)
        nZix=sNT(length(zix))
        zixVegs[cpI] = zix
        push!(nzixVegs, nZix)
        cpI = cpI + 1
    end
    ttwo = sNT(2.0)
    ## pack land variables
    @pack_land (cAlloc, cpNames, cAllocVeg, zixVegs, nzixVegs, ttwo) => land.states
    return land
end



function compute(o::cAllocation_GSI, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)

    ## unpack land variables
    @unpack_land begin
        (cAlloc, cpNames, cAllocVeg, zixVegs, nzixVegs, ttwo) ∈ land.states
        fW ∈ land.cAllocationSoilW
        fT ∈ land.cAllocationSoilT
        sNT ∈ helpers.numbers
    end

    # allocation to root; wood & leaf
    cAllocVeg[1] = fW / ((fW + fT) * ttwo)
    cAllocVeg[2] = fW / ((fW + fT) * ttwo)
    cAllocVeg[3] = fT / (fW + fT)

    for ind in 1:3
        foreach(zixVegs[ind]) do ix
            cAlloc[ix] = cAllocVeg[ind]  / nzixVegs[ind]
        end
    end

    return land
end

@doc """
compute the fraction of NPP that is allocated to the different plant organs. In this case; the allocation is dynamic in time according to temperature; water & radiation stressors computed from GSI approach.

---

# compute:
Combine the different effects of carbon allocation using cAllocation_GSI

*Inputs*
 - land.cAllocationRadiation.fR: radiation stressors for carbo allocation
 - land.cAllocationSoilW.fT: temperature stressors for carbon allocation
 - land.cAllocationSoilW.fW: water stressors for carbon allocation

*Outputs*
 - land.states.cAlloc: the fraction of NPP that is allocated to the different plant organs
 - land.states.cAlloc

# precompute:
precompute/instantiate time-invariant variables for cAllocation_GSI


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