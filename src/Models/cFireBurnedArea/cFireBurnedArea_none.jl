export cFireBurnedArea_none

struct cFireBurnedArea_none <: cFireBurnedArea end

function define(params::cFireBurnedArea_none, forcing, land, helpers)
    return land
end

@doc """
TODO
"""
cFireBurnedArea_none
