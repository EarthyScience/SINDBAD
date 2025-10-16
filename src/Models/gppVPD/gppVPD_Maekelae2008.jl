export gppVPD_Maekelae2008

#! format: off
@bounds @describe @units @timescale @with_kw struct gppVPD_Maekelae2008{T1} <: gppVPD
    k::T1 = 0.4 | (0.06, 0.7) | "empirical parameter assuming typically negative values" | "kPa-1" | ""
end
#! format: on

function compute(params::gppVPD_Maekelae2008, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppVPD_Maekelae2008 params
    @unpack_nt f_VPD_day ⇐ forcing
    @unpack_nt o_one ⇐ land.constants

    ## calculate variables
    gpp_f_vpd = exp(-k * f_VPD_day)
    gpp_f_vpd = minOne(gpp_f_vpd)

    ## pack land variables
    @pack_nt gpp_f_vpd ⇒ land.diagnostics
    return land
end

purpose(::Type{gppVPD_Maekelae2008}) = "VPD stress on GPP potential based on Maekelae (2008)."

@doc """

$(getModelDocString(gppVPD_Maekelae2008))

---

# Extended help

*References*

*Versions*

*Created by*
 - ncarvalhais

*Notes*
 - Equation 5. a negative exponent is introduced to have positive parameter  values
"""
gppVPD_Maekelae2008
