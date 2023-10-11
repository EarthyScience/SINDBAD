export gppVPD_none

struct gppVPD_none <: gppVPD end

function define(params::gppVPD_none, forcing, land, helpers)

    ## calculate variables
    # set scalar to a constant one [no effect on potential GPP]
    gpp_f_vpd = land.wCycleBase.o_one

    ## pack land variables
    @pack_land gpp_f_vpd => land.gppVPD
    return land
end

@doc """
sets the VPD stress on gpp_potential to one (no stress)

---

# compute:

*Inputs*
 - helpers

*Outputs*
 - land.gppVPD.gpp_f_vpd: VPD effect on GPP between 0-1

# instantiate:
instantiate/instantiate time-invariant variables for gppVPD_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppVPD_none
