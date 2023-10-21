export percolation_WBP

struct percolation_WBP <: percolation end

function compute(params::percolation_WBP, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (ΔgroundW, ΔsoilW, soilW, groundW) ∈ land.pools
        WBP ∈ land.states
        (o_one, n_groundW) ∈ land.constants
        tolerance ∈ helpers.numbers
        wSat ∈ land.properties
    end

    # set WBP as the soil percolation
    percolation = WBP
    to_allocate = o_one * percolation
    for sl ∈ eachindex(land.pools.soilW)
        allocated = min(wSat[sl] - (soilW[sl] + ΔsoilW[sl]), to_allocate)
        @add_to_elem allocated → (ΔsoilW, sl, :soilW)
        to_allocate = to_allocate - allocated
    end
    to_groundW = to_allocate / n_groundW
    ΔgroundW = addToEachElem(ΔgroundW, to_groundW)
    # to_groundW = abs(to_allocate)
    # ΔgroundW = addToEachElem(ΔgroundW, to_groundW / n_groundW)
    to_allocate = to_allocate - to_groundW
    WBP = to_allocate

    ## pack land variables
    @pack_land begin
        percolation → land.fluxes
        WBP → land.states
        (ΔgroundW, ΔsoilW) → land.pools
    end
    return land
end

function update(params::percolation_WBP, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.pools
    end

    ## update variables
    # update soil moisture of the first layer
    soilW .= soilW .+ ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW .= ΔsoilW .- ΔsoilW

    ## pack land variables
    @pack_land begin
        soilW → land.pools
        # ΔsoilW → land.pools
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
