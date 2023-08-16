export gppVPD_PRELES

#! format: off
@bounds @describe @units @with_kw struct gppVPD_PRELES{T1,T2,T3,T4} <: gppVPD
    κ::T1 = 0.4 | (0.06, 0.7) | "" | "kPa-1"
    Cκ::T2 = 0.4 | (-50.0, 10.0) | "" | ""
    Ca0::T3 = 295.0 | (250.0, 500.0) | "" | "ppm"
    Cm::T4 = 2000.0 | (400.0, 4000.0) | "" | "ppm"
end
#! format: on

function compute(p_struct::gppVPD_PRELES, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppVPD_PRELES p_struct
    @unpack_forcing VPDDay ∈ forcing

    ## unpack land variables
    @unpack_land begin
        ambient_CO2 ∈ land.states
        o_one ∈ land.wCycleBase
    end
    # fVPD_VPD                    = exp(p.gppfVPD.kappa .* -f.VPDDay(:,tix) .* (p.gppfVPD.Ca0 ./ s.cd.ambCO2) .^ -p.gppfVPD.Ckappa);
    # fCO2_CO2                    = 1 + (s.cd.ambCO2 - p.gppfVPD.Ca0) ./ (s.cd.ambCO2 - p.gppfVPD.Ca0 + p.gppfVPD.Cm);
    # VPDScGPP                    = max(0, min(1, fVPD_VPD .* fCO2_CO2));
    # d.gppfVPD.VPDScGPP(:,tix)	= VPDScGPP;

    ## calculate variables
    fVPD_VPD = exp(-κ * VPDDay * (Ca0 / ambient_CO2)^-Cκ)
    fCO2_CO2 = o_one + (ambient_CO2 - Ca0) / (ambient_CO2 - Ca0 + Cm)
    gpp_f_vpd = clampZeroOne(fVPD_VPD * fCO2_CO2)

    ## pack land variables
    @pack_land gpp_f_vpd => land.gppVPD
    return land
end

@doc """
VPD stress on gpp_potential based on Maekelae2008 and with co2 effect based on PRELES model

# Parameters
$(SindbadParameters)

---

# compute:
Vpd effect using gppVPD_PRELES

*Inputs*
 - Cam: parameter modulation mean co2 effect on GPP
 - cKappa: parameter modulating co2 effect on VPD response to GPP
 - forcing.VPDDay: daytime vapor pressure deficit [kPa]
 - κ: parameter of the exponential decay function of GPP with  VPD [kPa-1] dimensionless [0.06 0.7]; median !0.4, same as k from  Maekaelae 2008

*Outputs*
 - land.gppVPD.gpp_f_vpd: VPD effect on GPP between 0-1

---

# Extended help

*References*
 - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in  Europe. Global change biology, 14[1], 92-108.
 - http://www.metla.fi/julkaisut/workingpapers/2012/mwp247.pdf

*Versions*
 - 1.1 on 22.11.2020 [skoirala]: changing units to kpa for vpd & sign of  κ to match with Maekaelae2008  

*Created by:*
 - ncarval

*Notes*
 - sign of exponent is changed to have κ parameter as positive values
"""
gppVPD_PRELES
