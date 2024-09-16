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

@doc """
sets the temperature stress on gpp_potential to one (no stress)

---

# compute:
Effect of temperature using gppAirT_none

*Inputs*
 - helpers

*Outputs*
 - land.diagnostics.gpp_f_airT: effect of temperature on potential GPP

# instantiate:
instantiate/instantiate time-invariant variables for gppAirT_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppAirT_none
