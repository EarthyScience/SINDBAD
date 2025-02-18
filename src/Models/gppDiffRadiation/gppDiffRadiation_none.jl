export gppDiffRadiation_none

struct gppDiffRadiation_none <: gppDiffRadiation end

function define(params::gppDiffRadiation_none, forcing, land, helpers)
    @unpack_nt o_one ⇐ land.constants

    ## calculate variables
    # set scalar to a constant one [no effect on potential GPP]
    gpp_f_cloud = o_one

    ## pack land variables
    @pack_nt gpp_f_cloud ⇒ land.diagnostics
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
 - land.diagnostics.gpp_f_cloud: effect of cloudiness on potential GPP

# Instantiate:
Instantiate time-invariant variables for gppDiffRadiation_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - mjung
 - ncarvalhais
"""
gppDiffRadiation_none
