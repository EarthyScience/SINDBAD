export gppDirRadiation_none

struct gppDirRadiation_none <: gppDirRadiation end

function define(params::gppDirRadiation_none, forcing, land, helpers)
    @unpack_nt o_one ⇐ land.constants
    ## calculate variables
    gpp_f_light = o_one

    ## pack land variables
    @pack_nt gpp_f_light ⇒ land.diagnostics
    return land
end

purpose(::Type{gppDirRadiation_none}) = "sets the light saturation scalar [light effect] on gpp_potential to one"

@doc """

$(getBaseDocString(gppDirRadiation_none))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [`skoirala | @dr-ko`]: documentation & clean up 

*Created by*
 - mjung
 - ncarvalhais
"""
gppDirRadiation_none
