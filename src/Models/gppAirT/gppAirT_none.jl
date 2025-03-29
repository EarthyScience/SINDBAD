export gppAirT_none

struct gppAirT_none <: gppAirT end

function define(params::gppAirT_none, forcing, land, helpers)
    @unpack_nt o_one ⇐ land.constants

    ## calculate variables
    # set scalar to a constant o_one [no effect on potential GPP]
    gpp_f_airT = o_one

    ## pack land variables
    @pack_nt gpp_f_airT ⇒ land.diagnostics
    return land
end

purpose(::Type{gppAirT_none}) = "sets the temperature stress on gpp_potential to one (no stress)"

@doc """

$(getBaseDocString(gppAirT_none))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarvalhais
"""
gppAirT_none
