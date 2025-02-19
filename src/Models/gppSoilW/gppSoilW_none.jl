export gppSoilW_none

struct gppSoilW_none <: gppSoilW end

function define(params::gppSoilW_none, forcing, land, helpers)
    @unpack_nt o_one ⇐ land.constants

    ## calculate variables
    # set scalar to a constant one [no effect on potential GPP]
    gpp_f_soilW = o_one

    ## pack land variables
    @pack_nt gpp_f_soilW ⇒ land.diagnostics
    return land
end

@doc """
sets the soil moisture stress on gpp_potential to one (no stress)

---

# compute:

*Inputs*
 - helpers

*Outputs*
 - land.diagnostics.gpp_f_soilW: soil moisture effect on GPP [] dimensionless, between 0-1

# Instantiate:
Instantiate time-invariant variables for gppSoilW_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarvalhais
"""
gppSoilW_none
