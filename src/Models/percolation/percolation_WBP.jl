export percolation_WBP

struct percolation_WBP <: percolation end

function define(p_struct::percolation_WBP, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        z_zero ∈ land.wCycleBase
    end

    # set WBP as the soil percolation
    percolation = z_zero
    WBP = z_zero

    ## pack land variables
    @pack_land begin
        percolation => land.fluxes
        WBP => land.states
    end
    return land
end

function compute(p_struct::percolation_WBP, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (soilW, groundW) ∈ land.pools
        (ΔgroundW, ΔsoilW, WBP) ∈ land.states
        (z_zero, o_one, n_groundW) ∈ land.wCycleBase
        tolerance ∈ helpers.numbers
        wSat ∈ land.soilWBase
    end

    # set WBP as the soil percolation
    percolation = WBP
    toAllocate = percolation
    if toAllocate > z_zero
        ΔsoilW, toAllocate = inner_toAlloc(land.pools.soilW, wSat, soilW, ΔsoilW, toAllocate, helpers)
    end
    to_groundW = abs(toAllocate)
    ΔgroundW = addToEachElem(ΔgroundW, to_groundW / n_groundW)
    toAllocate = toAllocate - to_groundW
    WBP = abs(toAllocate) > tolerance ? toAllocate : z_zero

    ## pack land variables
    @pack_land begin
        percolation => land.fluxes
        WBP => land.states
        (ΔgroundW, ΔsoilW) => land.states
    end
    return land
end

function inner_toAlloc(land_pools_soilW, wSat, soilW, ΔsoilW, toAllocate, helpers)
    for sl ∈ eachindex(land_pools_soilW)
        allocated = min(wSat[sl] - (soilW[sl] + ΔsoilW[sl]), toAllocate)
        @add_to_elem allocated => (ΔsoilW, sl, :soilW)
        toAllocate = toAllocate - allocated
    end
    return ΔsoilW, toAllocate
end

function update(p_struct::percolation_WBP, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
    end

    ## update variables
    # update soil moisture of the first layer
    soilW .= soilW .+ ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW .= ΔsoilW .- ΔsoilW

    ## pack land variables
    @pack_land begin
        soilW => land.pools
        # ΔsoilW => land.states
    end
    return land
end
@doc """
computes the percolation into the soil after the surface runoff process

---

# compute:
Calculate the soil percolation = wbp at this point using percolation_WBP

*Inputs*
 - land.states.WBP: water budget pool

*Outputs*
 - land.land.fluxes: soil percolation

# update

update pools and states in percolation_WBP
 - land.states.WBP

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
percolation_WBP
