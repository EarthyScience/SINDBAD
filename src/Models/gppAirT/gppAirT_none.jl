export gppAirT_none

struct gppAirT_none <: gppAirT end

function define(params::gppAirT_none, forcing, land, helpers)

    ## calculate variables
    # set scalar to a constant o_one [no effect on potential GPP]
    gpp_f_airT = land.wCycleBase.o_one

    ## pack land variables
    @pack_land gpp_f_airT => land.gppAirT
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
 - land.gppAirT.gpp_f_airT: effect of temperature on potential GPP

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
