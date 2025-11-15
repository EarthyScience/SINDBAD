export cFireMortality_none

struct cFireMortality_none <: cFireMortality end

function define(params::cFireMortality_none, forcing, land, helpers)
    return land
end

@doc """
TODO
"""
cFireMortality_none
