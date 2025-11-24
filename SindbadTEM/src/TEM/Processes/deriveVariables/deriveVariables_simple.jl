export deriveVariables_simple

struct deriveVariables_simple <: deriveVariables end

function compute(params::deriveVariables_simple, forcing, land, helpers)
    return land
end

purpose(::Type{deriveVariables_simple}) = "Incudes derivation of few variables that may be commonly needed for optimization against some datasets."

@doc """

$(getProcessDocstring(deriveVariables_simple))

----

# Extended help

*References*

*Versions*
 - 1.0 on 19.07.2023 [skoirala | @dr-ko]:

*Created by*
 - skoirala | @dr-ko
"""
deriveVariables_simple
