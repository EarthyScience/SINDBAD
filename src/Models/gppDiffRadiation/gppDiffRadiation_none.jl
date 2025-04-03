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

purpose(::Type{gppDiffRadiation_none}) = "sets the cloudiness scalar [radiation diffusion] for gpp_potential to one"

@doc """

$(getBaseDocString(gppDiffRadiation_none))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation & clean up 

*Created by*
 - mjung
 - ncarvalhais
"""
gppDiffRadiation_none
