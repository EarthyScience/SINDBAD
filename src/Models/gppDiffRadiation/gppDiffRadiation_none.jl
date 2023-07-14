export gppDiffRadiation_none

struct gppDiffRadiation_none <: gppDiffRadiation end

function define(p_struct::gppDiffRadiation_none, forcing, land, helpers)

    ## calculate variables
    # set scalar to a constant one [no effect on potential GPP]
    gpp_f_cloud = helpers.numbers.𝟙

    ## pack land variables
    @pack_land gpp_f_cloud => land.gppDiffRadiation
    return land
end

@doc """
sets the cloudiness scalar [radiation diffusion] for gpp_potential to one

---

# compute:
Effect of diffuse radiation using gppDiffRadiation_none

*Inputs*
 - helpers

*Outputs*
 - land.gppDiffRadiation.gpp_f_cloud: effect of cloudiness on potential GPP

# instantiate:
instantiate/instantiate time-invariant variables for gppDiffRadiation_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - mjung
 - ncarval
"""
gppDiffRadiation_none
