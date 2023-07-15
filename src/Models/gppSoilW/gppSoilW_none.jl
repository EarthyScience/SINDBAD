export gppSoilW_none

struct gppSoilW_none <: gppSoilW end

function define(p_struct::gppSoilW_none, forcing, land, helpers)

    ## calculate variables
    # set scalar to a constant one [no effect on potential GPP]
    gpp_f_soilW = land.wCycleBase.o_one

    ## pack land variables
    @pack_land gpp_f_soilW => land.gppSoilW
    return land
end

@doc """
sets the soil moisture stress on gpp_potential to one (no stress)

---

# compute:

*Inputs*
 - helpers

*Outputs*
 - land.gppSoilW.gpp_f_soilW: soil moisture effect on GPP [] dimensionless, between 0-1

# instantiate:
instantiate/instantiate time-invariant variables for gppSoilW_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppSoilW_none
