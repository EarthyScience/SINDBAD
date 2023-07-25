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
        percolation => fluxes.percolation
        WBP => land.states
    end
    return land
end

function compute(p_struct::percolation_WBP, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (soilW, groundW) ∈ land.pools
        (ΔsoilW, WBP) ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
        tolerance ∈ helpers.numbers
        wSat ∈ land.soilWBase
    end

    # set WBP as the soil percolation
    percolation = WBP
    toAllocate = percolation
    if toAllocate > z_zero
        for sl ∈ eachindex(land.pools.soilW)
            allocated = min(wSat[sl] - (soilW[sl] + ΔsoilW[sl]), toAllocate)
            @add_to_elem allocated => (ΔsoilW, sl, :soilW)
            toAllocate = toAllocate - allocated
        end
    end
    WBP = abs(toAllocate) > tolerance ? toAllocate : z_zero

    ## pack land variables
    @pack_land begin
        percolation => fluxes.percolation
        WBP => land.states
        ΔsoilW => land.states
    end
    return land
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
 - land.fluxes.percolation: soil percolation

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
