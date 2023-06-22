export cTauSoilT_none

struct cTauSoilT_none <: cTauSoilT end

function define(o::cTauSoilT_none, forcing, land, helpers)

    ## calculate variables
    fT = helpers.numbers.𝟙

    ## pack land variables
    @pack_land fT => land.cTauSoilT
    return land
end

@doc """
set the outputs to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTauSoilT_none


---

# Extended help
"""
cTauSoilT_none
