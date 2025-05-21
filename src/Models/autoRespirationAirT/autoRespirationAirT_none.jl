export autoRespirationAirT_none

struct autoRespirationAirT_none <: autoRespirationAirT end

function define(params::autoRespirationAirT_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    auto_respiration_f_airT = one(first(cEco))

    ## pack land variables
    @pack_nt auto_respiration_f_airT ⇒ land.diagnostics
    return land
end

purpose(::Type{autoRespirationAirT_none}) = "sets the temperature effect on autotrophic respiration to one (i.e. no effect)"

@doc """

$(getModelDocString(autoRespirationAirT_none))

---

# Extended help
"""
autoRespirationAirT_none
