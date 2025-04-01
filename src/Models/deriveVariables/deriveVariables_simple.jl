export deriveVariables_simple

struct deriveVariables_simple <: deriveVariables end

function compute(params::deriveVariables_simple, forcing, land, helpers)
    @unpack_nt cVegWood ⇐ land.pools
    ## calculate variables
    aboveground_biomass = cVegWood[1]
    @pack_nt aboveground_biomass ⇒ land.states
    return land
end

purpose(::Type{deriveVariables_simple}) = "derives variables from other sindbad models and saves them into land.deriveVariables"

@doc """

$(getBaseDocString(deriveVariables_simple))

----

# Extended help

*References*

*Versions*
 - 1.0 on 19.07.2023 [`skoirala | @dr-ko`]:

*Created by*
 - `skoirala | @dr-ko`
"""
deriveVariables_simple
