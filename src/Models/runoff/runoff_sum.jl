export runoff_sum

struct runoff_sum <: runoff end

function define(p_struct::runoff_sum, forcing, land, helpers)

    ## set variables to zero
    base_runoff = land.wCycleBase.z_zero
    runoff = land.wCycleBase.z_zero
    surface_runoff = land.wCycleBase.z_zero

    ## pack land variables
    @pack_land begin
        (runoff, base_runoff, surface_runoff) => land.fluxes
    end
    return land
end

function compute(p_struct::runoff_sum, forcing, land, helpers)

    ## unpack land variables
    @unpack_land (base_runoff, surface_runoff) ∈ land.fluxes

    ## calculate variables
    runoff = surface_runoff + base_runoff

    ## pack land variables
    @pack_land runoff => land.fluxes
    return land
end

@doc """
calculates runoff as a sum of all potential components

---

# compute:
Calculate the total runoff as a sum of components using runoff_sum

*Inputs*
 - land.fluxes.base_runoff
 - land.fluxes.surface_runoff

*Outputs*
 - land.fluxes.runoff

# instantiate:
instantiate/instantiate time-invariant variables for runoff_sum


---

# Extended help

*References*

*Versions*
 - 1.0 on 01.04.2022  

*Created by:*
 - skoirala
"""
runoff_sum
