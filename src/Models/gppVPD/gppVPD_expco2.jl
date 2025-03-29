export gppVPD_expco2

#! format: off
@bounds @describe @units @timescale @with_kw struct gppVPD_expco2{T1,T2,T3} <: gppVPD
    κ::T1 = 0.4 | (0.06, 0.7) | "" | "kPa-1" | ""
    c_κ::T2 = 0.4 | (-50.0, 10.0) | "exponent of co2 modulation of vpd effect" | "" | ""
    base_ambient_CO2::T3 = 380.0 | (300.0, 500.0) | "" | "ppm" | ""
end
#! format: on

function compute(params::gppVPD_expco2, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppVPD_expco2 params
    @unpack_nt f_VPD_day ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        ambient_CO2 ⇐ land.states
        (z_zero, o_one) ⇐ land.constants
    end

    ## calculate variables
    fVPD_VPD = exp(κ * -f_VPD_day * (ambient_CO2 / base_ambient_CO2)^-c_κ)
    gpp_f_vpd = clampZeroOne(fVPD_VPD)

    ## pack land variables
    @pack_nt gpp_f_vpd ⇒ land.diagnostics
    return land
end

purpose(::Type{gppVPD_expco2}) = "VPD stress on gpp_potential based on Maekelae2008 and with co2 effect"

@doc """

$(getBaseDocString())

---

# Extended help

*References*
 - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in  Europe. Global change biology, 14[1], 92-108.
 - http://www.metla.fi/julkaisut/workingpapers/2012/mwp247.pdf

*Versions*
 - 1.1 on 22.11.2020 [skoirala]: changing units to kpa for vpd & sign of  κ to match with Maekaelae2008  

*Created by:*
 - ncarvalhais

*Notes*
 - sign of exponent is changed to have κ parameter as positive values
"""
gppVPD_expco2
