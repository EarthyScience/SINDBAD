export gppDemand_none

struct gppDemand_none <: gppDemand end

function define(params::gppDemand_none, forcing, land, helpers)
    @unpack_nt (o_one, z_zero) ⇐ land.constants

    gpp_f_climate = o_one

    # compute demand GPP with no stress. gpp_f_climate is set to ones in the prec; & hence the demand have no stress in GPP.
    gpp_demand = z_zero

    ## pack land variables
    @pack_nt (gpp_f_climate, gpp_demand) ⇒ land.diagnostics
    return land
end

purpose(::Type{gppDemand_none}) = "sets the scalar for demand GPP to ones & demand GPP to zero"

@doc """

$(getBaseDocString(gppDemand_none))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation & clean up 

*Created by*
 - ncarvalhais
"""
gppDemand_none
