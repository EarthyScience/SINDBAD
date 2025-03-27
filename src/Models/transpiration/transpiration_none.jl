export transpiration_none

struct transpiration_none <: transpiration end

function define(params::transpiration_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants
    ## calculate variables
    transpiration = z_zero

    ## pack land variables
    @pack_nt transpiration ⇒ land.fluxes
    return land
end

@doc """
sets the actual transpiration to zero

# Instantiate:
Instantiate time-invariant variables for transpiration_none


---

# Extended help
"""
transpiration_none
