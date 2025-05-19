export gppVPD_MOD17

#! format: off
@bounds @describe @units @timescale @with_kw struct gppVPD_MOD17{T1,T2} <: gppVPD
    VPD_max::T1 = 4.0 | (2.0, 8.0) | "Max VPD with GPP > 0" | "kPa" | ""
    VPD_min::T2 = 0.65 | (0.0, 1.0) | "Min VPD with GPP > 0" | "kPa" | ""
end
#! format: on

function compute(params::gppVPD_MOD17, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppVPD_MOD17 params
    @unpack_nt f_VPD_day ⇐ forcing
    @unpack_nt (z_zero, o_one) ⇐ land.constants

    ## calculate variables
    vsc = (VPD_max - f_VPD_day) / (VPD_max - VPD_min)
    gpp_f_vpd = clampZeroOne(vsc)

    ## pack land variables
    @pack_nt gpp_f_vpd ⇒ land.diagnostics
    return land
end

purpose(::Type{gppVPD_MOD17}) = "VPD stress on gpp_potential based on MOD17 model"

@doc """

$(getModelDocString(gppVPD_MOD17))

---

# Extended help

*References*
 - MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
 - Running; S. W.; Nemani; R. R.; Heinsch; F. A.; Zhao; M.; Reeves; M.  & Hashimoto, H. (2004). A continuous satellite-derived measure of  global terrestrial primary production. Bioscience, 54[6], 547-560.
 - Zhao, M., Heinsch, F. A., Nemani, R. R., & Running, S. W. (2005)  Improvements of the MODIS terrestrial gross & net primary production  global data set. Remote sensing of Environment, 95[2], 164-176.

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation & clean up  

*Created by*
 - ncarvalhais

*Notes*
"""
gppVPD_MOD17
