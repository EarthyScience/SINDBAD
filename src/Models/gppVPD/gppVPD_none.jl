export gppVPD_none

struct gppVPD_none <: gppVPD end

function define(params::gppVPD_none, forcing, land, helpers)
    @unpack_nt o_one ⇐ land.constants

    ## calculate variables
    # set scalar to a constant one [no effect on potential GPP]
    gpp_f_vpd = o_one

    ## pack land variables
    @pack_nt gpp_f_vpd ⇒ land.diagnostics
    return land
end

purpose(::Type{gppVPD_none}) = "sets the VPD stress on gpp_potential to one (no stress)"

@doc """

$(getBaseDocString(gppVPD_none))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation & clean up  

*Created by*
 - ncarvalhais
"""
gppVPD_none
