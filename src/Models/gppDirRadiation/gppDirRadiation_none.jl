export gppDirRadiation_none

struct gppDirRadiation_none <: gppDirRadiation end

function define(p_struct::gppDirRadiation_none, forcing, land, helpers)

    ## calculate variables
    gpp_f_light = helpers.numbers.𝟙

    ## pack land variables
    @pack_land gpp_f_light => land.gppDirRadiation
    return land
end

@doc """
sets the light saturation scalar [light effect] on gpp_potential to one

---

# compute:
Effect of direct radiation using gppDirRadiation_none

*Inputs*
 - helpers

*Outputs*
 - land.gppDirRadiation.gpp_f_light: effect of light saturation on potential GPP

# instantiate:
instantiate/instantiate time-invariant variables for gppDirRadiation_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - mjung
 - ncarval
"""
gppDirRadiation_none
