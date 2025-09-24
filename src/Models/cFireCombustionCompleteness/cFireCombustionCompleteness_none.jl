export cFireCombustionCompleteness_none

struct cFireCombustionCompleteness_none <: cFireCombustionCompleteness end

function define(params::cFireCombustionCompleteness_none, forcing, land, helpers)
    return land
end

@doc """
TODO
"""
cFireCombustionCompleteness_none
