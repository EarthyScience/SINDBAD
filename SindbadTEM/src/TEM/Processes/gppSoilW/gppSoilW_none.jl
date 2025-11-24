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

purpose(::Type{gppSoilW_none}) = "Sets soil moisture stress on GPP potential to 1 (no stress)."

@doc """

$(getProcessDocstring(gppSoilW_none))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation & clean up  

*Created by*
 - ncarvalhais
"""
gppSoilW_none
